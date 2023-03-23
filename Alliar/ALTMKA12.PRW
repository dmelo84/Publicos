//-------------------------------------------------------------------
/*{Protheus.doc} ConsOCOF3()
Consulta Ocorrencia F3

@author Itamar Gama .:
@since  27/03/2017
@version P12
*/
//-------------------------------------------------------------------
User Function ConsOCOF3()
Local bRet := .F.

Private cPosAss	   := aScan(aHeader, {|x| alltrim(x[2]) == "UD_ASSUNTO"})  
Private cPosOco    := aScan(aHeader, {|x| alltrim(x[2]) == "UD_OCORREN"})
Private cPosTPO    := aScan(aHeader, {|x| alltrim(x[2]) == "UD_XCODTPO"})
Private cCodigo    := Alltrim(&(ReadVar()))
Private cCodigo1   := Alltrim("M->UD_OCORREN")

Private aCpoRet	   := {,,,}	
M->UD_OCORREN:=''
bRet := FiltraSU9(aCols[n][cPosTPO]+aCols[n][cPosAss])     

Return(bRet)


Static Function FiltraSU9(cChave)

Local cQuery	 	:= ""
Local oLstSU9 		:= nil   
Private oDlgSU9 	:= nil
Private _bRet 		:= .F.
Private aDadosSU9	:= {}

//Query de assuntos
cQuery := "SELECT SU9.U9_CODIGO, SU9.U9_DESC"
cQuery += " FROM "+RetSQLName("SU9") +" SU9" 
cQuery += " WHERE SU9.U9_TIPOOCO = '"+LEFT(cChave,6)+"' AND SU9.U9_ASSUNTO = '"+RIGHT(cChave,6)+"' AND SU9.D_E_L_E_T_ = ''"  
cQuery += " ORDER BY SU9.U9_CODIGO "

cAlias1:= CriaTrab(Nil,.F.)
DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cAlias1, .F., .T.)
     
(cAlias1)->(DbGoTop())     
If (cAlias1)->(Eof())
     Aviso( "Assuntos", "Não existe dados a consultar", {"Ok"} )
     Return .F.
Endif

Do While (cAlias1)->(!Eof())
   
     aAdd( aDadosSU9, { (cAlias1)->U9_CODIGO, (cAlias1)->U9_DESC} )
     
    (cAlias1)->(DbSkip())
    
Enddo

DbCloseArea(cAlias1)     

nList := aScan(aDadosSU9, {|x| alltrim(x[1]) == alltrim(cCodigo)})

iif(nList = 0,nList := 1,nList)

//--Montagem da Tela
Define MsDialog oDlgSU9 Title "Ocorrências" From 0,0 To 280, 500 Of oMainWnd Pixel

@ 5,5 LISTBOX oLstSU9 ;
          VAR lVarMat ;
          Fields HEADER "Ocorrência", "Desc Ocorrência";
          SIZE 245,110 On DblClick ( ConfSU9(oLstSU9:nAt, @aDadosSU9, @_bRet) ) ;
          OF oDlgSU9 PIXEL       

oLstSU9:SetArray(aDadosSU9)
oLstSU9:nAt := nList
oLstSU9:bLine := { || {aDadosSU9[oLstSU9:nAt,1], aDadosSU9[oLstSU9:nAt,2]}}

DEFINE SBUTTON FROM 122,5 TYPE 1 ACTION ConfSU9(oLstSU9:nAt, @aDadosSU9, @_bRet) ENABLE OF oDlgSU9     
DEFINE SBUTTON FROM 122,40 TYPE 2 ACTION oDlgSU9:End() ENABLE OF oDlgSU9

Activate MSDialog oDlgSU9 Centered

Return _bRet


Static Function ConfSU9(_nPos, aDadosSU9, _bRet)   

cCodigo := aDadosSU9[_nPos,1]   
aCols[n,cPosOco] := cCodigo    
aCols[n,cPosOco+1] := aDadosSU9[_nPos,2] 

aCpoRet[1] := cCodigo    //Não esquecer de alimentar essa variável quando for f3 pois ela e o retorno e se estiver com valor diferente complica.
aCpoRet[2] := aDadosSU9[_nPos,2] 
_bRet := .T.

oDlgSU9:End()
     
Return