#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} UPALLIAR
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  08/01/2016
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPALLIAR( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
Local   cDesc4    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk
	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else
		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualização Realizada.", "UPALLIAR" )
				Else
					MsgStop( "Atualização não Realizada.", "UPALLIAR" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização Concluída." )
				Else
					Final( "Atualização não Realizada." )
				EndIf
			EndIf

		Else
			MsgStop( "Atualização não Realizada.", "UPALLIAR" )

		EndIf

	Else
		MsgStop( "Atualização não Realizada.", "UPALLIAR" )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  08/01/2016
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// Só adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Versão.............: " + GetVersao(.T.) )
			AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Estação............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			FSAtuSX3()

			//------------------------------------
			// Atualiza o dicionário SIX
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuSIX()

			oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )

			// Alteração física dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					AutoGrLog( "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] )
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nI

		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  08/01/2016
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cSeqAtu   := ""
Local cX3Campo  := ""
Local cX3Dado   := ""
Local nI        := 0
Local nJ        := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nPosVld   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->(FIELDGET(FIELDPOS("X3_CAMPO"))) )

Local nXGSIZE 	:= FIELDPOS("XG_SIZE")
Local nXGGRUPO  := FIELDPOS("XG_GRUPO")

AutoGrLog( "Ínicio da Atualização" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
             { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
             { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
             { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
             { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
             { "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
             { "X3_AGRUP"  , 0 }, { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )


//
// Campos Tabela SA2
//
aAdd( aSX3, { ;
	'SA2'																	, ; //X3_ARQUIVO
	'J9'																	, ; //X3_ORDEM
	'A2_XIDFLG'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'ID FLUIG'																, ; //X3_TITULO
	'ID FLUIG'																, ; //X3_TITSPA
	'ID FLUIG'																, ; //X3_TITENG
	'ID FLUIG'																, ; //X3_DESCRIC
	'ID FLUIG'																, ; //X3_DESCSPA
	'ID FLUIG'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

//
// Campos Tabela SB1
//
aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'R3'																	, ; //X3_ORDEM
	'B1_XCONTA2'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'CONTA2'																, ; //X3_TITULO
	'CONTA2'																, ; //X3_TITSPA
	'CONTA2'																, ; //X3_TITENG
	'CONTA2'																, ; //X3_DESCRIC
	'CONTA2'																, ; //X3_DESCSPA
	'CONTA2'																, ; //X3_DESCENG
	'!@'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'R4'																	, ; //X3_ORDEM
	'B1_XIDFLG'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'ID FLUIG'																, ; //X3_TITULO
	'ID FLUIG'																, ; //X3_TITSPA
	'ID FLUIG'																, ; //X3_TITENG
	'ID FLUIG'																, ; //X3_DESCRIC
	'ID FLUIG'																, ; //X3_DESCSPA
	'ID FLUIG'																, ; //X3_DESCENG
	'!@'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'R5'																	, ; //X3_ORDEM
	'B1_ZMARCEX'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	50																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Marc.Exclu.'															, ; //X3_TITULO
	'Marc.Exclu.'															, ; //X3_TITSPA
	'Marc.Exclu.'															, ; //X3_TITENG
	'Marc.Exclu.'															, ; //X3_DESCRIC
	'Marc.Exclu.'															, ; //X3_DESCSPA
	'Marc.Exclu.'															, ; //X3_DESCENG
	'!@'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'R6'																	, ; //X3_ORDEM
	'B1_ZMARPRE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	50																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Marc.Pref.'															, ; //X3_TITULO
	'Marc.Pref.'															, ; //X3_TITSPA
	'Marc.Pref.'															, ; //X3_TITENG
	'Marc.Pref.'															, ; //X3_DESCRIC
	'Marc.Pref.'															, ; //X3_DESCSPA
	'Marc.Pref.'															, ; //X3_DESCENG
	'!@'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'R7'																	, ; //X3_ORDEM
	'B1_ZRESMAR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	50																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Marc.Forn.'															, ; //X3_TITULO
	'Marc.Forn.'															, ; //X3_TITSPA
	'Marc.Forn.'															, ; //X3_TITENG
	'Marc.Forn.'															, ; //X3_DESCRIC
	'Marc.Forn.'															, ; //X3_DESCSPA
	'Marc.Forn.'															, ; //X3_DESCENG
	'!@'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'R8'																	, ; //X3_ORDEM
	'B1_XMARCEX'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	50																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Marc.Exclu.'															, ; //X3_TITULO
	'Marc.Exclu.'															, ; //X3_TITSPA
	'Marc.Exclu.'															, ; //X3_TITENG
	'Marc.Exclu.'															, ; //X3_DESCRIC
	'Marc.Exclu.'															, ; //X3_DESCSPA
	'Marc.Exclu.'															, ; //X3_DESCENG
	'!@'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'R9'																	, ; //X3_ORDEM
	'B1_XMARPRE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	50																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Marc.Pref.'															, ; //X3_TITULO
	'Marc.Pref.'															, ; //X3_TITSPA
	'Marc.Pref.'															, ; //X3_TITENG
	'Marc.Pref.'															, ; //X3_DESCRIC
	'Marc.Pref.'															, ; //X3_DESCSPA
	'Marc.Pref.'															, ; //X3_DESCENG
	'!@'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'S0'																	, ; //X3_ORDEM
	'B1_XRESMAR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	50																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Marc.Forn.'															, ; //X3_TITULO
	'Marc.Forn.'															, ; //X3_TITSPA
	'Marc.Forn.'															, ; //X3_TITENG
	'Marc.Forn.'															, ; //X3_DESCRIC
	'Marc.Forn.'															, ; //X3_DESCSPA
	'Marc.Forn.'															, ; //X3_DESCENG
	'!@'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

//
// Campos Tabela SBM
//
aAdd( aSX3, { ;
	'SBM'																	, ; //X3_ARQUIVO
	'18'																	, ; //X3_ORDEM
	'BM_XCONTA1'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'C.Contabil 1'															, ; //X3_TITULO
	'C.Contabil 1'															, ; //X3_TITSPA
	'C.Contabil 1'															, ; //X3_TITENG
	'C.Contabil 1'															, ; //X3_DESCRIC
	'C.Contabil 1'															, ; //X3_DESCSPA
	'C.Contabil 1'															, ; //X3_DESCENG
	'!@'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CT1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SBM'																	, ; //X3_ARQUIVO
	'19'																	, ; //X3_ORDEM
	'BM_XCONTA2'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'C.Contabil 2'															, ; //X3_TITULO
	'C.Contabil 2'															, ; //X3_TITSPA
	'C.Contabil 2'															, ; //X3_TITENG
	'C.Contabil 2'															, ; //X3_DESCRIC
	'C.Contabil 2'															, ; //X3_DESCSPA
	'C.Contabil 2'															, ; //X3_DESCENG
	'!@'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CT1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

//
// Campos Tabela SC1
//
aAdd( aSX3, { ;
	'SC1'																	, ; //X3_ARQUIVO
	'92'																	, ; //X3_ORDEM
	'C1_XIDFLG'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'ID FLUIG'																, ; //X3_TITULO
	'ID FLUIG'																, ; //X3_TITSPA
	'ID FLUIG'																, ; //X3_TITENG
	'ID FLUIG'																, ; //X3_DESCRIC
	'ID FLUIG'																, ; //X3_DESCSPA
	'ID FLUIG'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC1'																	, ; //X3_ARQUIVO
	'93'																	, ; //X3_ORDEM
	'C1_XTPSCFL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tp.SC Fluig'															, ; //X3_TITULO
	'Tp.SC Fluig'															, ; //X3_TITSPA
	'Tp.SC Fluig'															, ; //X3_TITENG
	'Tipo SC Fluig'															, ; //X3_DESCRIC
	'Tipo SC Fluig'															, ; //X3_DESCSPA
	'Tipo SC Fluig'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

//
// Campos Tabela SC7
//
aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'H0'																	, ; //X3_ORDEM
	'C7_XIDFLG'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'ID FLUIG'																, ; //X3_TITULO
	'ID FLUIG'																, ; //X3_TITSPA
	'ID FLUIG'																, ; //X3_TITENG
	'ID FLUIG'																, ; //X3_DESCRIC
	'ID FLUIG'																, ; //X3_DESCSPA
	'ID FLUIG'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

//
// Campos Tabela SCR
//
aAdd( aSX3, { ;
	'SCR'																	, ; //X3_ARQUIVO
	'24'																	, ; //X3_ORDEM
	'CR_XIDFLG'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'ID FLUIG'																, ; //X3_TITULO
	'ID FLUIG'																, ; //X3_TITSPA
	'ID FLUIG'																, ; //X3_TITENG
	'ID FLUIG'																, ; //X3_DESCRIC
	'ID FLUIG'																, ; //X3_DESCSPA
	'ID FLUIG'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SCR'																	, ; //X3_ARQUIVO
	'23'																	, ; //X3_ORDEM
	'CR_FLUIG'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Sol. Fluig'															, ; //X3_TITULO
	'Sol. Fluig'															, ; //X3_TITSPA
	'Fluig req'																, ; //X3_TITENG
	'Solicitação Fluig'														, ; //X3_DESCRIC
	'Solicitud Fluig'														, ; //X3_DESCSPA
	'Fluig request'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(132) + Chr(128)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'N'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME


//
// Campos Tabela SE5
//
aAdd( aSX3, { ;
	'SE5'																	, ; //X3_ARQUIVO
	'A4'																	, ; //X3_ORDEM
	'E5_XIDFLG'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'ID FLUIG'																, ; //X3_TITULO
	'ID FLUIG'																, ; //X3_TITSPA
	'ID FLUIG'																, ; //X3_TITENG
	'ID FLUIG'																, ; //X3_DESCRIC
	'ID FLUIG'																, ; //X3_DESCSPA
	'ID FLUIG'																, ; //X3_DESCENG
	'!@'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

//
// Campos Tabela SF1
//
aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'F2'																	, ; //X3_ORDEM
	'F1_XIDFLG'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'ID FLUIG'																, ; //X3_TITULO
	'ID FLUIG'																, ; //X3_TITSPA
	'ID FLUIG'																, ; //X3_TITENG
	'ID FLUIG'																, ; //X3_DESCRIC
	'ID FLUIG'																, ; //X3_DESCSPA
	'ID FLUIG'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'F3'																	, ; //X3_ORDEM
	'F1_USERID'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	50																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Mat.Usuário'															, ; //X3_TITULO
	'Reg.Usuario'															, ; //X3_TITSPA
	'User Registr'															, ; //X3_TITENG
	'Matrícula do Usuário'													, ; //X3_DESCRIC
	'Registro de Usuario'													, ; //X3_DESCSPA
	"User's Registration"													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME
	
aAdd( aSX3, { ;
	'SA6'																	, ; //X3_ARQUIVO
	'73'																	, ; //X3_ORDEM
	'A6_XEMPFIL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	11																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Empr.Filial'															, ; //X3_TITULO
	'Empr.Filial'															, ; //X3_TITSPA
	'Empr.Filial'															, ; //X3_TITENG
	'Empresa Filial'													, ; //X3_DESCRIC
	'Empresa Filial'													, ; //X3_DESCSPA
	"Empresa Filial"													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

//
// Atualizando dicionário
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->(FIELDGET(nXGSIZE))
				aSX3[nI][nPosTam] := SXG->(FIELDGET(nXGSIZE))
				AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->(FIELDGET(nXGSIZE)) ) ) + "]" + CRLF + ;
				" por pertencer ao grupo de campos [" + SXG->(FIELDGET(nXGGRUPO)) + "]" + CRLF )
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->(FIELDGET(FIELDPOS("X3_ARQUIVO"))) == cAliasAtu )
				cSeqAtu := SX3->(FIELDGET(FIELDPOS("X3_ORDEM")))
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )

			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ] ) )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		AutoGrLog( "Criado campo " + aSX3[nI][nPosCpo] )

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX
Função de processamento da gravação do SIX - Indices

@author TOTVS Protheus
@since  08/01/2016
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSIX()
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SIX" + CRLF )

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
             "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Tabela SA2
//
aAdd( aSIX, { ;
	'SA2'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'A2_FILIAL+A2_COD+A2_LOJA'												, ; //CHAVE
	'Codigo + Loja'															, ; //DESCRICAO
	'Codigo + Tienda'														, ; //DESCSPA
	'Supplier + Unit'														, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SA2'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'A2_FILIAL+A2_NOME+A2_LOJA'												, ; //CHAVE
	'Razao Social + Loja'													, ; //DESCRICAO
	'Razon Social + Tienda'													, ; //DESCSPA
	'Name + Unit'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SA2'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'A2_FILIAL+A2_CGC'														, ; //CHAVE
	'CNPJ/CPF'																, ; //DESCRICAO
	'CNPJ/CPF'																, ; //DESCSPA
	'CNPJ/CPF'																, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SA2'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'A2_FILIAL+A2_ID_FBFN'													, ; //CHAVE
	'Identificac.'															, ; //DESCRICAO
	'Identificac.'															, ; //DESCSPA
	'Identificat.'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SA2'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'A2_FILIAL+A2_CONREG+A2_SIGLCR'											, ; //CHAVE
	'Numero C.R + Sigla C.R'												, ; //DESCRICAO
	'Numero C.R. + Sigla C.R.'												, ; //DESCSPA
	'Reg.Coun.No. + C.R Acronym'											, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SA2'																	, ; //INDICE
	'6'																		, ; //ORDEM
	'A2_FILIAL+A2_VINCULO'													, ; //CHAVE
	'P. Vinculo'															, ; //DESCRICAO
	'P. Vinculo'															, ; //DESCSPA
	'P.Emp.Bond'															, ; //DESCENG
	'S'																		, ; //PROPRI
	'CC1'																	, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SA2'																	, ; //INDICE
	'7'																		, ; //ORDEM
	'A2_FILIAL+A2_NUMRA'													, ; //CHAVE
	'Cód Func'																, ; //DESCRICAO
	'Cod. Empl.'															, ; //DESCSPA
	'Empl. code'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SA2'																	, ; //INDICE
	'8'																		, ; //ORDEM
	'A2_FILIAL+A2_CODADM'													, ; //CHAVE
	'Cód. Adm.'																, ; //DESCRICAO
	'Cod. Adm.'																, ; //DESCSPA
	'Inst.Code'																, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SA2'																	, ; //INDICE
	'9'																		, ; //ORDEM
	'A2_FILIAL+A2_IDHIST'													, ; //CHAVE
	'ID Hist.'																, ; //DESCRICAO
	'ID Hist.'																, ; //DESCSPA
	'Hist. ID'																, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SB1
//
aAdd( aSIX, { ;
	'SB1'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'B1_FILIAL+B1_COD'														, ; //CHAVE
	'Codigo'																, ; //DESCRICAO
	'Codigo'																, ; //DESCSPA
	'Product'																, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SB1'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'B1_FILIAL+B1_TIPO+B1_COD'												, ; //CHAVE
	'Tipo + Codigo'															, ; //DESCRICAO
	'Tipo + Codigo'															, ; //DESCSPA
	'Type + Product'														, ; //DESCENG
	'S'																		, ; //PROPRI
	'02'																	, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SB1'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'B1_FILIAL+B1_DESC+B1_COD'												, ; //CHAVE
	'Descricao + Codigo'													, ; //DESCRICAO
	'Descripcion + Codigo'													, ; //DESCSPA
	'Description + Product'													, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SB1'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'B1_FILIAL+B1_GRUPO+B1_COD'												, ; //CHAVE
	'Grupo + Codigo'														, ; //DESCRICAO
	'Grupo + Codigo'														, ; //DESCSPA
	'Inven.Group + Product'													, ; //DESCENG
	'S'																		, ; //PROPRI
	'SBM'																	, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SB1'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'B1_FILIAL+B1_CODBAR'													, ; //CHAVE
	'Cod Barras'															, ; //DESCRICAO
	'Cod. Barras'															, ; //DESCSPA
	'Bar Code'																, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SB1'																	, ; //INDICE
	'6'																		, ; //ORDEM
	'B1_FILIAL+B1_PROC'														, ; //CHAVE
	'Forn. Padrao'															, ; //DESCRICAO
	'Prove.Estand'															, ; //DESCSPA
	'Supplier'																, ; //DESCENG
	'S'																		, ; //PROPRI
	'SA2'																	, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SB1'																	, ; //INDICE
	'7'																		, ; //ORDEM
	'B1_FILIAL+B1_GRUPO+B1_CODITE'											, ; //CHAVE
	'Grupo + Cod Item'														, ; //DESCRICAO
	'Grupo + Cod Item'														, ; //DESCSPA
	'Inven.Group + Item Code'												, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SB1'																	, ; //INDICE
	'8'																		, ; //ORDEM
	'B1_FILIAL+B1_CCCUSTO+B1_GCCUSTO'										, ; //CHAVE
	'CC p/ Custo + Gr Cnt Custo'											, ; //DESCRICAO
	'CC p/ Costo + Gr Cnt Costo'											, ; //DESCSPA
	'CC f/ Cost + Gr Cost Cent'												, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SB1'																	, ; //INDICE
	'9'																		, ; //ORDEM
	'B1_FILIAL+B1_BASE2'													, ; //CHAVE
	'SubSubFamil'															, ; //DESCRICAO
	'SubSubFamil'															, ; //DESCSPA
	'SubSubFamil'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SB1'																	, ; //INDICE
	'A'																		, ; //ORDEM
	'B1_FILIAL+B1_BASE3'													, ; //CHAVE
	'SFamilia'																, ; //DESCRICAO
	'SFamilia'																, ; //DESCSPA
	'SFamily'																, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SB1'																	, ; //INDICE
	'B'																		, ; //ORDEM
	'B1_FILIAL+B1_IDHIST'													, ; //CHAVE
	'ID.Hist.'																, ; //DESCRICAO
	'ID.Hist.'																, ; //DESCSPA
	'Hist. ID'																, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SBM
//
aAdd( aSIX, { ;
	'SBM'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'BM_FILIAL+BM_GRUPO'													, ; //CHAVE
	'Cod Grupo'																, ; //DESCRICAO
	'Cod. Grupo'															, ; //DESCSPA
	'Group Code'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SBM'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'BM_FILIAL+BM_DESC'														, ; //CHAVE
	'Desc Grupo'															, ; //DESCRICAO
	'Desc. Grupo'															, ; //DESCSPA
	'Group Descr.'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SC1
//
aAdd( aSIX, { ;
	'SC1'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'C1_FILIAL+C1_NUM+C1_ITEM'												, ; //CHAVE
	'Numero da SC + Item da SC'												, ; //DESCRICAO
	'Nro.Solc.Com + Item Sl.Comp'											, ; //DESCSPA
	'P.R. No. + Pur.Req.Item'												, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC1'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'C1_FILIAL+C1_PRODUTO+C1_NUM+C1_ITEM+C1_FORNECE+C1_LOJA'				, ; //CHAVE
	'Produto + Numero da SC + Item da SC + Fornecedor + Loja do Forn'		, ; //DESCRICAO
	'Producto + Nro.Solc.Com + Item Sl.Comp + Proveedor + Tda. Proveed'		, ; //DESCSPA
	'Product + P.R. No. + Pur.Req.Item + Supplier + Unit'					, ; //DESCENG
	'S'																		, ; //PROPRI
	'SB1+XXX+XXX+SA2'														, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC1'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'C1_FILIAL+C1_FORNECE+C1_LOJA+C1_PRODUTO+C1_DESCRI+DTOS(C1_DATPRF)'		, ; //CHAVE
	'Fornecedor + Loja do Forn + Produto + Descricao + Necessidade'			, ; //DESCRICAO
	'Proveedor + Tda. Proveed + Producto + Descripcion + Necesidad'			, ; //DESCSPA
	'Supplier + Unit + Product + Description + Necessity'					, ; //DESCENG
	'S'																		, ; //PROPRI
	'SA2+XXX+SB1'															, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC1'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'C1_FILIAL+C1_OP+C1_NUM+C1_ITEM'										, ; //CHAVE
	'Ord Producao + Numero da SC + Item da SC'								, ; //DESCRICAO
	'Ord. Prodn. + Nro.Solc.Com + Item Sl.Comp'								, ; //DESCSPA
	'Prod.Order + P.R. No. + Pur.Req.Item'									, ; //DESCENG
	'S'																		, ; //PROPRI
	'SC2'																	, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC1'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'C1_FILIAL+C1_COTACAO+C1_PRODUTO+C1_IDENT'								, ; //CHAVE
	'Num. Cotacao + Produto + Identif.'										, ; //DESCRICAO
	'Nro.Cotizac. + Producto + Identif.'									, ; //DESCSPA
	'Quot. No. + Product + Identifier'										, ; //DESCENG
	'S'																		, ; //PROPRI
	'XXX+SB1'																, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC1'																	, ; //INDICE
	'6'																		, ; //ORDEM
	'C1_FILIAL+C1_PEDIDO+C1_ITEMPED+C1_PRODUTO'								, ; //CHAVE
	'Num. Pedido + Item Pedido + Produto'									, ; //DESCRICAO
	'Num. Pedido + Item Pedido + Producto'									, ; //DESCSPA
	'Order + Item Ordered + Product'										, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC1'																	, ; //INDICE
	'7'																		, ; //ORDEM
	'C1_FILIAL+C1_TPOP+C1_OP+C1_NUM+C1_ITEM'								, ; //CHAVE
	'Tipo Op + Ord Producao + Numero da SC + Item da SC'					, ; //DESCRICAO
	'Tipo Op + Ord. Prodn. + Nro.Solc.Com + Item Sl.Comp'					, ; //DESCSPA
	'Type of PO + Prod.Order + P.R. No. + Pur.Req.Item'						, ; //DESCENG
	'S'																		, ; //PROPRI
	'XXX+SC2'																, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC1'																	, ; //INDICE
	'8'																		, ; //ORDEM
	'C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO+C1_NUM+C1_ITEM'					, ; //CHAVE
	'Cod. Edital + Nr. Processo + Produto + Numero da SC + Item da SC'		, ; //DESCRICAO
	'Cod. Edicto + Nº Proceso + Producto + Nro.Solc.Com + Item Sl.Comp'		, ; //DESCSPA
	'Notice Cd. + Process Numb + Product + P.R. No. + Pur.Req.Item'			, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	'GCP01'																	, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC1'																	, ; //INDICE
	'9'																		, ; //ORDEM
	'C1_FILIAL+C1_ACCNUM+C1_ACCITEM'										, ; //CHAVE
	'Sol. ACC + Item ACC'													, ; //DESCRICAO
	'Sol. ACC + Item ACC'													, ; //DESCSPA
	'ACC Req. + ACC Item'													, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	'ACC'																	, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC1'																	, ; //INDICE
	'A'																		, ; //ORDEM
	'C1_FILIAL+C1_ORCAM'													, ; //CHAVE
	'No Orcamento'															, ; //DESCRICAO
	'Nr.Presupues'															, ; //DESCSPA
	'Quotation Nr'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC1'																	, ; //INDICE
	'B'																		, ; //ORDEM
	'C1_FISCORI+C1_SCORI+C1_ITSCORI+C1_PRODUTO'								, ; //CHAVE
	'Fil. Origem + SC Origem + Item Origem + Produto'						, ; //DESCRICAO
	'Suc.Origen + SC Origen + Item Origen + Producto'						, ; //DESCSPA
	'Source br. + Origin PR + Source Item + Product'						, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SC7
//
aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN'									, ; //CHAVE
	'Numero PC + Item + Sequencia'											, ; //DESCRICAO
	'Nr.PedCompra + Item + Secuencia'										, ; //DESCSPA
	'PO Number + Item + Sequence'											, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'C7_FILIAL+C7_PRODUTO+C7_FORNECE+C7_LOJA+C7_NUM'						, ; //CHAVE
	'Produto + Fornecedor + Loja + Numero PC'								, ; //DESCRICAO
	'Producto + Proveedor + Tienda + Nr.PedCompra'							, ; //DESCSPA
	'Product + Supplier + Unit + PO Number'									, ; //DESCENG
	'S'																		, ; //PROPRI
	'SB1+FOR'																, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'C7_FILIAL+C7_FORNECE+C7_LOJA+C7_NUM'									, ; //CHAVE
	'Fornecedor + Loja + Numero PC'											, ; //DESCRICAO
	'Proveedor + Tienda + Nr.PedCompra'										, ; //DESCSPA
	'Supplier + Unit + PO Number'											, ; //DESCENG
	'S'																		, ; //PROPRI
	'FOR'																	, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'C7_FILIAL+C7_PRODUTO+C7_NUM+C7_ITEM+C7_SEQUEN'							, ; //CHAVE
	'Produto + Numero PC + Item + Sequencia'								, ; //DESCRICAO
	'Producto + Nr.PedCompra + Item + Secuencia'							, ; //DESCSPA
	'Product + PO Number + Item + Sequence'									, ; //DESCENG
	'S'																		, ; //PROPRI
	'SB1'																	, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'C7_FILIAL+DTOS(C7_EMISSAO)+C7_NUM+C7_ITEM+C7_SEQUEN'					, ; //CHAVE
	'DT Emissao + Numero PC + Item + Sequencia'								, ; //DESCRICAO
	'Fch Emision + Nr.PedCompra + Item + Secuencia'							, ; //DESCSPA
	'Issue Date + PO Number + Item + Sequence'								, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'6'																		, ; //ORDEM
	'C7_FILENT+C7_PRODUTO+C7_FORNECE+C7_LOJA+C7_NUM'						, ; //CHAVE
	'Filial Entr. + Produto + Fornecedor + Loja + Numero PC'				, ; //DESCRICAO
	'Suc. Entrega + Producto + Proveedor + Tienda + Nr.PedCompra'			, ; //DESCSPA
	'Branch Deliv + Product + Supplier + Unit + PO Number'					, ; //DESCENG
	'S'																		, ; //PROPRI
	'SB1+FOR'																, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'7'																		, ; //ORDEM
	'C7_FILIAL+C7_PRODUTO+DTOS(C7_DATPRF)'									, ; //CHAVE
	'Produto + Dt. Entrega'													, ; //DESCRICAO
	'Producto + Fch Entrega'												, ; //DESCSPA
	'Product + Delivery Dt.'												, ; //DESCENG
	'S'																		, ; //PROPRI
	'SB1'																	, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'8'																		, ; //ORDEM
	'C7_FILIAL+C7_OP+C7_NUM+C7_ITEM+C7_SEQUEN'								, ; //CHAVE
	'OP. + Numero PC + Item + Sequencia'									, ; //DESCRICAO
	'Orden Produc + Nr.PedCompra + Item + Secuencia'						, ; //DESCSPA
	'Prod.Order + PO Number + Item + Sequence'								, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'9'																		, ; //ORDEM
	'C7_FILENT+C7_FORNECE+C7_LOJA+C7_NUM'									, ; //CHAVE
	'Filial Entr. + Fornecedor + Loja + Numero PC'							, ; //DESCRICAO
	'Suc. Entrega + Proveedor + Tienda + Nr.PedCompra'						, ; //DESCSPA
	'Branch Deliv + Supplier + Unit + PO Number'							, ; //DESCENG
	'S'																		, ; //PROPRI
	'FOR'																	, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'A'																		, ; //ORDEM
	'C7_FILIAL+STR(C7_TIPO,1)+C7_NUM+C7_ITEM+C7_SEQUEN'						, ; //CHAVE
	'Tipo + Numero PC + Item + Sequencia'									, ; //DESCRICAO
	'Tipo + Nr.PedCompra + Item + Secuencia'								, ; //DESCSPA
	'Type + PO Number + Item + Sequence'									, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'B'																		, ; //ORDEM
	'C7_FILIAL+C7_TPOP+C7_OP+C7_NUM+C7_ITEM+C7_SEQUEN'						, ; //CHAVE
	'Tipo Op + OP. + Numero PC + Item + Sequencia'							, ; //DESCRICAO
	'Tipo Op + Orden Produc + Nr.PedCompra + Item + Secuencia'				, ; //DESCSPA
	'Type of PO + Prod.Order + PO Number + Item + Sequence'					, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'C'																		, ; //ORDEM
	'C7_FILIAL+C7_APROV+C7_GRUPCOM'											, ; //CHAVE
	'Grupo Aprov. + Gr. Compras'											, ; //DESCRICAO
	'Grupo Aprob + Gr. Compras'												, ; //DESCSPA
	'Appr. Group + Buyers Grp'												, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'D'																		, ; //ORDEM
	'C7_FILENT+C7_PRODUTO+C7_FORNECE+C7_NUM'								, ; //CHAVE
	'Filial Entr. + Produto + Fornecedor + Numero PC'						, ; //DESCRICAO
	'Suc. Entrega + Producto + Proveedor + Nr.PedCompra'					, ; //DESCSPA
	'Branch Deliv + Product + Supplier + PO Number'							, ; //DESCENG
	'S'																		, ; //PROPRI
	'SB1+FOR'																, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'E'																		, ; //ORDEM
	'C7_FILENT+C7_NUM+C7_ITEM'												, ; //CHAVE
	'Filial Entr. + Numero PC + Item'										, ; //DESCRICAO
	'Suc. Entrega + Nr.PedCompra + Item'									, ; //DESCSPA
	'Branch Deliv + PO Number + Item'										, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'F'																		, ; //ORDEM
	'C7_FILIAL+C7_ENCER+C7_PRODUTO+DTOS(C7_EMISSAO)'						, ; //CHAVE
	'Ped. Encerr. + Produto + DT Emissao'									, ; //DESCRICAO
	'Ped.Concluid + Producto + Fch Emision'									, ; //DESCSPA
	'Closed Order + Product + Issue Date'									, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'G'																		, ; //ORDEM
	'C7_FILIAL+DTOS(C7_DATPRF)+C7_PRODUTO+C7_NUM+C7_ITEM+C7_SEQUEN'			, ; //CHAVE
	'Dt. Entrega + Produto + Numero PC + Item + Sequencia'					, ; //DESCRICAO
	'Fch Entrega + Producto + Nr.PedCompra + Item + Secuencia'				, ; //DESCSPA
	'Delivery Dt. + Product + PO Number + Item + Sequence'					, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'H'																		, ; //ORDEM
	'C7_FILENT+C7_FORNECE+C7_LOJA+C7_PRODUTO'								, ; //CHAVE
	'Filial Entr. + Fornecedor + Loja + Produto'							, ; //DESCRICAO
	'Suc. Entrega + Proveedor + Tienda + Producto'							, ; //DESCSPA
	'Branch Deliv + Supplier + Unit + Product'								, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'I'																		, ; //ORDEM
	'C7_FILENT+C7_FORNECE+C7_PRODUTO'										, ; //CHAVE
	'Filial Entr. + Fornecedor + Produto'									, ; //DESCRICAO
	'Suc. Entrega + Proveedor + Producto'									, ; //DESCSPA
	'Branch Deliv + Supplier + Product'										, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'J'																		, ; //ORDEM
	'C7_FILENT+C7_PRODUTO+C7_NUM+C7_ITEM'									, ; //CHAVE
	'Filial Entr. + Produto + Numero PC + Item'								, ; //DESCRICAO
	'Suc. Entrega + Producto + Nr.PedCompra + Item'							, ; //DESCSPA
	'Branch Deliv + Product + PO Number + Item'								, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'K'																		, ; //ORDEM
	'C7_FILIAL+C7_NODIA'													, ; //CHAVE
	'Seq. Diário'															, ; //DESCRICAO
	'Sec. Diario'															, ; //DESCSPA
	'Record Seq.'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'L'																		, ; //ORDEM
	'C7_FILIAL+C7_CODED+C7_NUMPR'											, ; //CHAVE
	'Cod. Edital + Nr. Processo'											, ; //DESCRICAO
	'Cod. Edicto + Nº Proceso'												, ; //DESCSPA
	'Notice Cd. + Process No.'												, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	'GCP01'																	, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC7'																	, ; //INDICE
	'M'																		, ; //ORDEM
	'C7_FILIAL+C7_LOTPLS+C7_CODRDA'											, ; //CHAVE
	'Lote Pls + Cod.RDA.Pag.'												, ; //DESCRICAO
	'Lote Pls + Cod.RDA.Pag.'												, ; //DESCSPA
	'Pls Lot + Paym. RDA Cd'												, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SCR
//
aAdd( aSIX, { ;
	'SCR'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL'										, ; //CHAVE
	'Tipo docto + Documento + Nivel'										, ; //DESCRICAO
	'Tipo docto + Documento + Nivel'										, ; //DESCSPA
	'Doc.Type + Document + Level'											, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SCR'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'CR_FILIAL+CR_TIPO+CR_NUM+CR_USER'										, ; //CHAVE
	'Tipo docto + Documento + Cod. Usuario'									, ; //DESCRICAO
	'Tipo docto + Documento + Usuario'										, ; //DESCSPA
	'Doc.Type + Document + User Code'										, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SE5
//
aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ'		, ; //CHAVE
	'DT Movimen + Banco + Agencia + Conta Banco + Num Cheque'				, ; //DESCRICAO
	'Fch Movimto. + Banco + Agencia + Cuenta Banco + Num. Cheque'			, ; //DESCSPA
	'Transact.Dt. + Bank + Bank Office + Bank Account + Cheque Numb.'		, ; //DESCENG
	'S'																		, ; //PROPRI
	'XXX+SA6'																, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ', ; //CHAVE
	'Tipo do Doc. + Prefixo + Titulo + Parcela + E5_TIPO+DT Movimen + Cli/F'	, ; //DESCRICAO
	'Tipo de Doc. + Prefijo + Titulo + Cuota + E5_TIPO+Fch Movimto. + Clien'	, ; //DESCSPA
	'Document Ty. + Prefix + Bill + Installment + E5_TIPO+Transact.Dt. + Cu'	, ; //DESCENG
	'S'																		, ; //PROPRI
	'XXX+XXX+XXX+XXX+05'													, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)', ; //CHAVE
	'Banco + Agencia + Conta Banco + Prefixo + Titulo + Parcela + E5_TIPO+D'	, ; //DESCRICAO
	'Banco + Agencia + Cuenta Banco + Prefijo + Titulo + Cuota + E5_TIPO+Fc'	, ; //DESCSPA
	'Bank + Bank Office + Bank Account + Prefix + Bill + Installment + E5_T'	, ; //DESCENG
	'S'																		, ; //PROPRI
	'SA6+XXX+XXX+XXX+XXX+XXX+05'											, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'E5_FILIAL+E5_NATUREZ+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(E5_DTDIGIT)+E5_RECPAG+E5_CLIFOR+E5_LOJA', ; //CHAVE
	'Natureza + Prefixo + Titulo + Parcela + E5_TIPO+Data Digit. + Rec/Pag'		, ; //DESCRICAO
	'Modalidad + Prefijo + Titulo + Cuota + E5_TIPO+Fecha Tipeo + Recibe/Pa'	, ; //DESCSPA
	'Class + Prefix + Bill + Installment + E5_TIPO+Typing Date + Receipt/Pa'	, ; //DESCENG
	'S'																		, ; //PROPRI
	'SED+XXX+XXX+XXX+05'													, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'E5_FILIAL+E5_LOTE+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)'	, ; //CHAVE
	'Lote + Prefixo + Titulo + Parcela + E5_TIPO+DT Movimen'				, ; //DESCRICAO
	'Lote + Prefijo + Titulo + Cuota + E5_TIPO+Fch Movimto.'				, ; //DESCSPA
	'Lot + Prefix + Bill + Installment + E5_TIPO+Transact.Dt.'				, ; //DESCENG
	'S'																		, ; //PROPRI
	'XXX+XXX+XXX+XXX+005'													, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'6'																		, ; //ORDEM
	'E5_FILIAL+DTOS(E5_DTDIGIT)+E5_NATUREZ'									, ; //CHAVE
	'Data Digit. + Natureza'												, ; //DESCRICAO
	'Fecha Tipeo + Modalidad'												, ; //DESCSPA
	'Typing Date + Class'													, ; //DESCENG
	'S'																		, ; //PROPRI
	'XXX+SED'																, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'7'																		, ; //ORDEM
	'E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ', ; //CHAVE
	'Prefixo + Titulo + Parcela + E5_TIPO+Cli/For + Loja + Sequencia'		, ; //DESCRICAO
	'Prefijo + Titulo + Cuota + E5_TIPO+Clien/Provee + Tienda + Secuencia'		, ; //DESCSPA
	'Prefix + Bill + Installment + E5_TIPO+Cust./Sup. + Store + Sequence'		, ; //DESCENG
	'S'																		, ; //PROPRI
	'XXX+XXX+XXX+05'														, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'8'																		, ; //ORDEM
	'E5_FILIAL+E5_ORDREC+E5_SERREC'											, ; //CHAVE
	'Rec/Ordem + Serie Recibo'												, ; //DESCRICAO
	'Rec/Orden + Serie Recibo'												, ; //DESCSPA
	'Rec./Order + RecSerialNbr'												, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'9'																		, ; //ORDEM
	'E5_FILIAL+E5_PROJPMS+E5_EDTPMS+E5_TASKPMS+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA', ; //CHAVE
	'Projeto + EDT + Tarefa + DT Movimen + Banco + Agencia + Conta Banco'		, ; //DESCRICAO
	'Proyecto + EDT + Tarea + Fch Movimto. + Banco + Agencia + Cuenta Banco'	, ; //DESCSPA
	'Project + EDT + Task + Transact.Dt. + Bank + Bank Office + Bank Accoun'	, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'A'																		, ; //ORDEM
	'E5_FILIAL+E5_DOCUMEN'													, ; //CHAVE
	'Documento'																, ; //DESCRICAO
	'Documento'																, ; //DESCSPA
	'Document'																, ; //DESCENG
	'S'																		, ; //PROPRI
	'XXX'																	, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'B'																		, ; //ORDEM
	'E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ+DTOS(E5_DATA)'		, ; //CHAVE
	'Banco + Agencia + Conta Banco + Num Cheque + DT Movimen'				, ; //DESCRICAO
	'Banco + Agencia + Cuenta Banco + Num. Cheque + Fch Movimto.'			, ; //DESCSPA
	'Bank + Bank Office + Bank Account + Cheque Numb. + Transact.Dt.'		, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'C'																		, ; //ORDEM
	'E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+DTOS(E5_DTDISPO)+E5_NUMCHEQ'	, ; //CHAVE
	'Banco + Agencia + Conta Banco + Data Dispon + Num Cheque'				, ; //DESCRICAO
	'Banco + Agencia + Cuenta Banco + Fch.Disponil + Num. Cheque'			, ; //DESCSPA
	'Bank + Bank Office + Bank Account + Avail.Date + Cheque Numb.'			, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'D'																		, ; //ORDEM
	'E5_FILIAL+E5_BANCO+DTOS(E5_DTDISPO)+E5_CONTA+E5_AGENCIA+E5_TIPODOC'	, ; //CHAVE
	'Banco + Data Dispon + Conta Banco + Agencia + Tipo do Doc.'			, ; //DESCRICAO
	'Banco + Fch.Disponil + Cuenta Banco + Agencia + Tipo de Doc.'			, ; //DESCSPA
	'Bank + Avail.Date + Bank Account + Bank Office + Document Ty.'			, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'E'																		, ; //ORDEM
	'E5_FILIAL+E5_NODIA'													, ; //CHAVE
	'Seq. Diario'															, ; //DESCRICAO
	'Seq. Diario'															, ; //DESCSPA
	'Record Seq.'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'F'																		, ; //ORDEM
	'E5_FILIAL+E5_PROCTRA'													, ; //CHAVE
	'Proc. Transf'															, ; //DESCRICAO
	'Proc. Transf'															, ; //DESCSPA
	'Trasn.Proc.'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'G'																		, ; //ORDEM
	'E5_FILIAL+E5_SITUA+E5_NATUREZ'											, ; //CHAVE
	'Situacao Frt + Natureza'												, ; //DESCRICAO
	'Situac.Frt + Modalidad'												, ; //DESCSPA
	'POS Status + Class'													, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'H'																		, ; //ORDEM
	'E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ+E5_TIPODOC+E5_SEQ'		, ; //CHAVE
	'Banco + Agencia + Conta Banco + Num Cheque + Tipo do Doc. + Sequencia'		, ; //DESCRICAO
	'Banco + Agencia + Cuenta Banco + Num. Cheque + Tipo de Doc. + Secuenci'	, ; //DESCSPA
	'Bank + Bank Office + Bank Account + Cheque Numb. + Document Ty. + Sequ'	, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'I'																		, ; //ORDEM
	'E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_BANCO+E5_MOEDA'						, ; //CHAVE
	'Prefixo + Titulo + Banco + Numerario'									, ; //DESCRICAO
	'Prefijo + Titulo + Banco + Numerario'									, ; //DESCSPA
	'Prefix + Bill + Bank + Number'											, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SF1
//
aAdd( aSIX, { ;
	'SF1'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO'					, ; //CHAVE
	'Numero + Serie + Fornecedor + Loja + Tipo da Nota'						, ; //DESCRICAO
	'Num. de Doc. + Serie + Proveedor + Tienda + Tipo Factura'				, ; //DESCSPA
	'Invoice + Series + Supplier + Unit + Invoice Type'						, ; //DESCENG
	'S'																		, ; //PROPRI
	'XXX+XXX+SA2'															, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SF1'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC'									, ; //CHAVE
	'Fornecedor + Loja + Numero'											, ; //DESCRICAO
	'Proveedor + Tienda + Num. de Doc.'										, ; //DESCSPA
	'Supplier + Unit + Invoice'												, ; //DESCENG
	'S'																		, ; //PROPRI
	'SA2'																	, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SF1'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'F1_FILIAL+F1_REMITO'													, ; //CHAVE
	'N§ Remito'																, ; //DESCRICAO
	''																		, ; //DESCSPA
	'N§ Del. Note'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SF1'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'F1_FILIAL+F1_ORDPAGO'													, ; //CHAVE
	'Ordem Pagto'															, ; //DESCRICAO
	'Orden Pago'															, ; //DESCSPA
	'PaymentOrder'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SF1'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'F1_FILIAL+F1_HAWB+F1_TIPO_NF+F1_DOC+F1_SERIE'							, ; //CHAVE
	'No. Conhec. + Tipo Docto. + Numero + Serie'							, ; //DESCRICAO
	'Conoc. Flete + Tipo Factura + Num. de Doc. + Serie'					, ; //DESCSPA
	'Way Bill + Invoice Type + Invoice + Series'							, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SF1'																	, ; //INDICE
	'6'																		, ; //ORDEM
	'F1_FILIAL+F1_NFELETR+DTOS(F1_EMINFE)+F1_FORNECE+F1_LOJA'				, ; //CHAVE
	'NF Eletr. + Emissão NF-e + Fornecedor + Loja'							, ; //DESCRICAO
	'Fact Electr. + Emis Fact E + Proveedor + Tienda'						, ; //DESCSPA
	'Elec. Inv. + Issue NF-e + Supplier + Unit'								, ; //DESCENG
	'S'																		, ; //PROPRI
	'XXX+XXX+SA2'															, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SF1'																	, ; //INDICE
	'7'																		, ; //ORDEM
	'F1_FILIAL+F1_NODIA'													, ; //CHAVE
	'Seq. Diário'															, ; //DESCRICAO
	'Sec. Diario'															, ; //DESCSPA
	'Tax Rec.Seq.'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SF1'																	, ; //INDICE
	'8'																		, ; //ORDEM
	'F1_FILIAL+F1_CHVNFE'													, ; //CHAVE
	'Chave NFe'																, ; //DESCRICAO
	'Clave e-Fact'															, ; //DESCSPA
	'NFe Key'																, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt    := .F.
	lDelInd := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		AutoGrLog( "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
	Else
		lAlt := .T.
		aAdd( aArqUpd, aSIX[nI][1] )
		If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "" ) == ;
		    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
			AutoGrLog( "Chave do índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
			lDelInd := .T. // Se for alteração precisa apagar o indice do banco
		EndIf
	EndIf

	RecLock( "SIX", !lAlt )
	For nJ := 1 To Len( aSIX[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
		EndIf
	Next nJ
	MsUnLock()

	dbCommit()

	If lDelInd
		TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
	EndIf

	oProcess:IncRegua2( "Atualizando índices..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleções feitas.
             Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
Local   cMascEmp  := "??"
Local   cVar      := ""
Local   lChk      := .F.
Local   lOk       := .F.
Local   lTeveMarc := .F.
Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

Local   aMarcadas := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), oDlg:End()  ) ;
Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  08/01/2016
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	//dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )
	OpenSM0()
	
	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  08/01/2016
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet


/////////////////////////////////////////////////////////////////////////////
