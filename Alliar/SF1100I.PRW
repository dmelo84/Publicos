#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} SF1100I
P.E.na inclusao do documento de entrada.
@author Augusto Ribeiro | www.compila.com.br
@since 27/02/2017
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function SF1100I()

//Declaracao Variaveis.
	Local aArea    := GetArea()
	Local aAreaSF1 := SF1->(GetArea())
	Local aRetAux	:= {}
	//hfp LOcal nAtivFluig
	Local cBanco := SA2->A2_BANCO  //abax-ja pego o campo aqui, para nao precisar reposicionar, caso desposicione *hfp - Compila


//Se Estado UF igual a MG ...
	If AllTrim(SF1->F1_EST) <> " "

		Do Case
		Case AllTrim(SA2->A2_COD_MUN)== "06200" .And. Alltrim(SF1->F1_ESPECIE) == "NFSE"

			If (RecLock("SF1",.F.))
				SF1->F1_XSERIED := "0"
				SF1->F1_XMODNF  := "5"
				
				MsUnLock()
			EndIf

		Case Alltrim(SF1->F1_ESPECIE) == "NFS"

			If (RecLock("SF1",.F.))
				SF1->F1_XSERIED := SF1->F1_SERIE
				SF1->F1_XMODNF  := "1"
				MsUnLock()
			EndIf

		Case Alltrim(SF1->F1_ESPECIE) == "NFF"

			If (RecLock("SF1",.F.))
				SF1->F1_XSERIED := SF1->F1_SERIE
				SF1->F1_XMODNF  := "2"
				MsUnLock()
			EndIf

		Case Alltrim(SA2->A2_COD_MUN) <> "06200"

			If (RecLock("SF1",.F.))
				SF1->F1_XSERIED := "0"
				SF1->F1_XMODNF  := "16"
				MsUnLock()
			EndIf
		EndCase
	EndIf


	// ------------------------------------------------------ Augusto Ribeiro | 27/02/2017 - 9:53:31 AM
	//	FLUIG - Finaliza processo no Fluig
	// ------------------------------------------------------------------------------------------
	IF !EMPTY(SF1->F1_XIDFLG)

		//	u_cpFaadd(@aCardData ,"voltaAtividadeNfeCanc"	,.T.)

		// ------------------------------------------------------ Augusto Ribeiro | 24/08/2017 - 2:37:47 PM
		//	Tratamento para processo de concessionárias
		//------------------------------------------------------------------------------------------
		nAtivFluig	:= 6
		IF SF1->F1_XFLUXOF == "3" // Honorarios Medicos
			nAtivFluig	:= 21
		ELSEIF Empty(SD1->D1_PEDIDO)
			nAtivFluig	:= 12
		endif

		IF !(ISBLIND())
			MsgRun ( "Integrando NF com Fluig...", "Integração Fluig", {|| aRetAux	:= U_cpFSSTsk(VAL(SF1->F1_XIDFLG), SF1->F1_USERID, nAtivFluig,"NF Classificada ("+ALLTRIM(UsrFullName(__CUSERID))+")" , .T., .F., /*aCardData */ ) } )
		ELSE
			aRetAux	:= U_cpFSSTsk(VAL(SF1->F1_XIDFLG), SF1->F1_USERID, nAtivFluig,"NF Classificada ("+ALLTRIM(UsrFullName(__CUSERID))+")" , .T., .F., /*aCardData */ )
		ENDIF


		IF !(aRetAux[1])
			Conout("SF1100I "+SF1->F1_XFLUXOF, "ERRO: "+aRetAux[2])
			Help(" ",1,"SF1100I",,aRetAux[2],4,5)
		ENDIF

	ENDIF

	// **********************************************************************
	// ajustes conforme taks 22238395 - c7_xtipdoc     // hfp* abax *compila  
	// trazer da PedCompra o tipo documento e gravar na SF1 E SE2.
	// abax -> qdo mais de um pedido nos itens, considerar o mais atual.
	// ********************************************************************
	ABAXF101(cBanco)  // abax
	// **************************************************************************


	RestArea(aAreaSF1)
	Restarea(aArea)

Return Nil


/*/{Protheus.doc} User Function nomeFunction
	Funcao para gravacao xTiodoc sf1 e se2  ABAX
	@type  Function
	@author user
	@since 25/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function ABAXF101(cBanco)  //ABAX
	Local jj

	//pegar os pedidos do SD1, para depois verificar qual pedido mais atual.
	aPedCom:={}
	aAreaSD1A:=	SD1->(GetArea())

	SD1->( DBSEEK(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE ))
	while !(SD1->(Eof()))  .AND. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE == xFILIAL("SD1")+SF1->F1_DOC+SF1->F1_SERIE

		IF aScan(aPedCom, SD1->D1_PEDIDO) == 0
			AADD(aPedCom, SD1->D1_PEDIDO)
		ENDIF


		SD1->(DBSKIP())
	ENDDO
	RestArea(aAreaSD1A)


	// bUSCA E VERIFICA QUAL PEDIDO MAIS NOVO.
	aAreaSC7	:= SC7->(GetArea())
	DbSelectArea("SC7")
	DbSetOrder(1)		//C7_FILIAL, C7_NUM

	aPedGrv	:= { CTOD(Space(8)), "", "", "",  0 }   //DATA, TIPDOC , JJ
	aPedGrv2	:= {} //{ {CTOD(Space(8)), "", "", "" }}

	For jj:=1 to Len(aPedCOm)
		cNumPed:= aPedCom[jj]

		If SC7->(DbSeek(xFilial("SC7") + cNumPed ))

			While !SC7->(Eof()) .AND. SC7->C7_FILIAL ==xFilial("SC7")  .AND. SC7->C7_NUM == cNumPed

				IF SC7->C7_EMISSAO >= aPedGrv[1]
					aPedGrv[1] := SC7->C7_EMISSAO
					aPedGrv[2] := SC7->C7_XTPDOC
					aPedGrv[3] := SC7->C7_XBUDGET
					aPedGrv[4] := 	SC7->C7_XMOTBUD
					//aPedGrv[5] := jj
				ENDIF

				//VERIFICA SE PRODUTO JA EXITE NO ARRAY. EM FUNCAO DA DATA E PRODUTO
				nPos:=aScan(aPedGrv2, {|x| x[2] == SC7->C7_PRODUTO} )

				//se nao tem adiciona
				IF nPos == 0
					AADD(aPedGrv2, {SC7->C7_EMISSAO,SC7->C7_PRODUTO,SC7->C7_XBUDGET,SC7->C7_XMOTBUD})
				ELSE
					//JA TEM, AJUSTA
					IF SC7->C7_EMISSAO >= aPedGrv2[nPos,1] // DATA É MAIOR
						aPedGrv2[nPos,3] := SC7->C7_XBUDGET
						aPedGrv2[nPos,4] := SC7->C7_XMOTBUD
					ENDIF
				ENDIF

				SC7->(DbSkip())

			EndDo
		EndIf

	Next

	RestArea(aAreaSC7)

 //Grava o tipo no SF1 //se nao estiver em branco, para nao "apagar" o que ja tem gravado vindo abax
	IF !Empty(aPedGrv[2])
		RecLock("SF1",.F.)
		SF1->F1_XTPDOC := aPedGrv[2]
		MsUnLock()

	ENDIF

   //grava no SE2  E MESMO TRATAMENTO DO vazio acima
	IF !Empty(aPedGrv[2])
		aAreaSE2	:= SE2->(GetArea())
		SE2->(dbSetOrder(1))
		SE2->( DbSeek(xFilial("SE2")+SF1->F1_PREFIXO+SF1->F1_DOC) )

		While !SE2->(Eof()) .And. xFilial("SE2") == SE2->E2_FILIAL .And. SF1->F1_PREFIXO == SE2->E2_PREFIXO .And.;
				SF1->F1_DOC == SE2->E2_NUM

			RecLock("SE2",.F.)
			
			SE2->E2_XTPDOC := SF1->F1_XTPDOC

			/*
			  HFP - Comlila
			  Trecho abaixo, copiado e adaptado do rdamake MT100GE2
			  para o correto ajuste do campo, caso haja modificacao no tipo 
		     do documento, e conseguentemente o E2_FORMPAG
			  *** caso altere a regra abaixo, alterar tambem no MT100GE2
			*/ 
			IF SF1->F1_XTPDOC == "DEP" .OR. SF1->F1_XTPINT == "HM"  //honorario medico
				IF cBanco == "341" 			
					E2_FORMPAG := "01"
				ELSEIF !Empty(cBanco)
					E2_FORMPAG := "41"
				ELSE	
					E2_FORMPAG := ""
				ENDIF 	
			ELSE
				E2_FORMPAG := ""
			ENDIF 

			MsUnLock()

			SE2->(dbSkip() )
		EndDo

		RestArea(aAreaSE2)  //hfp ajuste 20210730 

	ENDIF


   //20210807 acrescentado gravacao no sd1
	aAreaSD1A:=	SD1->(GetArea())

	SD1->( DBSEEK(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE ))
	while !(SD1->(Eof()))  .AND. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE == xFILIAL("SD1")+SF1->F1_DOC+SF1->F1_SERIE

		//PROCURA O PRODUTO NO ARRAY E TROCA SE TIVER PREENCHIDO
		nPos:=aScan(aPedGrv2, {|x| x[2] == SD1->D1_COD} )
		IF nPos <> 0
			IF !Empty(aPedGrv2[nPos,3])
				RecLock("SD1",.F.)
				SD1->D1_XBUDGET := aPedGrv2[nPos,3]
				MsUnLock()
			ENDIF

			IF !Empty(aPedGrv2[nPos,4])
				RecLock("SD1",.F.)
				SD1->D1_XMOTBUD := aPedGrv2[nPos,4]
				MsUnLock()
			ENDIF

		ENDIF

		SD1->(DBSKIP())

	ENDDO
	RestArea(aAreaSD1A)


Return

