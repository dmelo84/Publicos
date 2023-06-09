#INCLUDE "Protheus.ch"   

/* ------------------------------------------------------------------------------------------------------
@ Function F110FIL  - 	Faz a validacao de registros a serem marcados para baizas do contas a receber rotina 
@						Automatica.   
@ Autor 			: 	Francisco Lopes Junior                           
@ Objetivo			: 	A rotina dever� bloquear a baixa de t�tulos que n�o possu�rem o campo E1_NFELETR 
@						preenchido e oriundos do m�dulo faturamento E1_ORIGEM MATA460. Colocar o par�metro 
@						habilitavel por filial.
@						Desta maneira iremos estancar as futuras baixas de notas n�o autorizadas.           
@-------------------------------------------------------------------------------------------------------*/*
                            

User function F110FIL() 

local _aArea    := GetArea()
Local _lRet 	:= .T.  
Local _lRetFil 	:= GetMv("FS_FILBXNF",.F.,.F.) //par�metro se .T. passa na vali��o 
Local _cFiltro 	:= ""

		
	If _lRetFil
		_cFiltro := "  ((E1_NFELETR <> ' '  AND  LTRIM(RTRIM(UPPER(E1_ORIGEM))) = 'MATA460'  AND E1_FILIAL  IN ('"+ fwxfilial("SE1") +"')) OR E1_PREFIXO = 'MOT') "
	EndIf	
	
	If !Empty(_cFiltro)	
		_cFiltro += " AND ( E1_XUNVALC >= '"+MV_PAR11+"' AND E1_XUNVALC <= '"+MV_PAR12+"' )  "
	Else
		_cFiltro := " ( E1_XUNVALC >= '"+MV_PAR11+"' AND E1_XUNVALC <= '"+MV_PAR12+"' ) "
	Endif 

	/*	
	 If _lRetFil		
		_cFiltro := "  E1_NFELETR <> ' '  AND  LTRIM(RTRIM(UPPER(E1_ORIGEM))) = 'MATA460'  AND E1_FILIAL  IN ('"+ fwxfilial("SE1") +"')"
	 Else
	 
	 	_cFiltro 		:= ""
	 
	 EndIf
	 */

 RestArea(_aArea)
 
Return ( _cFiltro )




