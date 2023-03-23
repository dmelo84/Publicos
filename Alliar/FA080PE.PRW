#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} FA080PE
//TODO O ponto de entrada FA080PE sera executado na saida da funcao de baixa, 
//apos gravar todos os dados e após a contabilização
@author Mauro Nagata | www.compila.com.br 
@since 19/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function FA080PE()
Local aArea 	:= GetArea()
Local aAreaSE2	:= SE2->(GetArea())
Local aAreaSA2	:= SA2->(GetArea())
Local cChvTit	:= SE2->( E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCIR + MVTAXA )		//dados do título principal
Local cParcIR	:= SE2->E2_PARCIR
Local cCodRet	:= ""
Local lIp 		:= .F.

Do Case
	Case AllTrim(SE2->E2_NATUREZ) == "23030027"
	
			DbSelectArea("SE2")
			DbSetOrder(1)
			If DbSeek(cChvTit)
			
				//identificado o fornecedor do IR 
				DbSelectArea("SA2")
				If ( DbSeek( xFilial("SA2") + GetMV("MV_UNIAO") ) )
		   			cChvIR	:= SA2->( A2_COD + A2_LOJA )				
				EndIf
					
				DbSelectArea("SE2")
				
				Do While !Eof() .And. cChvTit == SE2->( E2_FILIAL + E2_PREFIXO + E2_NUM + cParcIR + E2_TIPO ) 
						
					If SE2->E2_TIPO == MVTAXA .And. cChvIR == SE2->( E2_FORNECE + E2_LOJA )
					
					    cCodRet := "0481"
			
						//atualizando o título a pagar relativo ao IR
						RecLock("SE2",.F.)
						SE2->E2_NATUREZ	:= "23030029"		
						SE2->E2_CODRET 	:= cCodRet
						SE2->E2_DIRF	:= "1"
						SE2->(MsUnLock())
						
						lIp := .T.
					EndIf
					
					DbSkip()
				EndDo
				
			EndIf
			
	Case AllTrim(SE2->E2_NATUREZ) == "23030028"
			
			DbSelectArea("SE2")
			DbSetOrder(1)
			If DbSeek(cChvTit)
			
				//identificado o fornecedor do IR 
				DbSelectArea("SA2")
				If ( DbSeek( xFilial("SA2") + GetMV("MV_UNIAO") ) )
		   			cChvIR	:= SA2->( A2_COD + A2_LOJA )				
				EndIf
					
				DbSelectArea("SE2")
				
				Do While !Eof() .And. cChvTit == SE2->( E2_FILIAL + E2_PREFIXO + E2_NUM + cParcIR + E2_TIPO ) 
						
					If SE2->E2_TIPO == MVTAXA .And. cChvIR == SE2->( E2_FORNECE + E2_LOJA )   
			
						cCodRet := "0481"
						
						//atualizando o título a pagar relativo ao IR
						RecLock("SE2",.F.)
						SE2->E2_NATUREZ	:= "23030030"		
						SE2->E2_CODRET 	:= cCodRet
						SE2->E2_DIRF	:= "1"
						SE2->(MsUnLock())
						
						lIp := .T.
					EndIf
					
					DbSkip()
				EndDo
				
			EndIf

	Case AllTrim(SE2->E2_NATUREZ) == "23060003"
			
			DbSelectArea("SE2")
			DbSetOrder(1)
			If DbSeek(cChvTit)
			
				//identificado o fornecedor do IR 
				DbSelectArea("SA2")
				If ( DbSeek( xFilial("SA2") + GetMV("MV_UNIAO") ) )
		   			cChvIR	:= SA2->( A2_COD + A2_LOJA )				
				EndIf
				
				DbSelectArea("SE2")
					
				Do While !Eof() .And. cChvTit == SE2->( E2_FILIAL + E2_PREFIXO + E2_NUM + cParcIR + E2_TIPO ) 
						
					If SE2->E2_TIPO == MVTAXA .And. cChvIR == SE2->( E2_FORNECE + E2_LOJA )   
			
						cCodRet := "5706"
						//atualizando o título a pagar relativo ao IR
						RecLock("SE2",.F.)
						SE2->E2_NATUREZ	:= "22010008"		
						SE2->E2_CODRET 	:= cCodRet
						SE2->E2_DIRF	:= "1"
						SE2->(MsUnLock())
						
						lIp := .T.
					EndIf
					
					DbSkip()
				EndDo
				
			EndIf
		
EndCase

RestArea(aAreaSE2)
//excluído bloco abaixo [Mauro Nagata, www.compila.com.br, 20200820]
/*
If lIp 
	RecLock("SE2", .F.)
	SE2->E2_CODRET 	:= cCodRet
	SE2->E2_DIRF	:= "2"
	SE2->(MsUnLock())
EndIf
*/
//fim bloco [Mauro Nagata, www.compila.com.br, 20200820]

RestArea(aAreaSA2)
RestArea(aAreaSE2)
RestArea(aArea)

Return

