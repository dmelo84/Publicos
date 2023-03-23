#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"



/*/{Protheus.doc} ALRFAT03
Executa o MSExecAuto no Ped de Vendas apos alteracao por P.E
@author Leandro Oliveira
@since 27/11/2015
@version 1.0
@return ${return}, ${return_description}
/*/
User Function ALRFAT03()

	Local aCabec := {}
	Local aItens := {}
	Local aLinhas:= {}	
	Local nX := 0 
	Local nL := 0
	
	ProcName(1)
	
	dbSelectArea("SC5")                 
	For nX := 1 To SC5->(FCount())
		aAdd(aCabec, {FieldName(nX), &("M->"+FieldName(nX)), Nil})   
	Next   
	
	SC5->(dbCloseArea())

	For nL := 1 to Len(aCols)
		If !aCols[nL,Len(aHeader)+1]    
			dbSelectArea("SC6")	 
			For nX := 1 To SC6->(FCount())
				if( ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == FieldName(nX)}) > 0 )
					aAdd(aItens, {FieldName(nX), Nil , Nil})   
				endif		
			Next	   
		
			For nX := 1 To Len(aItens)
				aItens[nX, 2] :=   aCols[nL,  ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == aItens[nX, 1]})]
			Next
		
			aAdd(aLinhas, aItens)
			aItens :={}
		Endif	
	Next


	BEGIN TRANSACTION
		lMsErroAuto := .F.
			      
		MSExecAuto({|x,y,z| Mata410(x,y,z)}, aCabec, aItens, 4)
		If lMsErroAuto
			MostraErro("C:\temp\erro_ms.log")
			DisarmTransaction()
			break
		EndIf	     
	END TRANSACTION


Return
