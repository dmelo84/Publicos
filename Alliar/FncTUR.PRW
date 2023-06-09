#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBSRV.CH"
#include "TOPCONN.CH"

User Function FncTURVl(aTrocaTurno, cMatSPF, cMsg)
	Local nRetorno := 1
	
	If aTrocaTurno:OPERACAO == 3
		If U_RegExiste("SPF",xFilial("SPF",aTrocaTurno:PF_FILIAL)+cMatSPF+DTOS(aTrocaTurno:PF_DATA))
			cMsg := "Troca de Turno j� cadastrada para a matr�cula!"
			nRetorno := 3 //Erro
			Return nRetorno
		EndIf
	EndIf
	
	If !NaoVazio(cMatSPF)
		cMsg := "A matr�cula dever� ser informada!"
		nRetorno := 3 //Erro
		Return nRetorno
	EndIf                                                                                                                      

	If !NaoVazio(aTrocaTurno:PF_DATA)
		cMsg := "A data dever� ser informada!"
		nRetorno := 3 //Erro
		Return nRetorno
	EndIf

	If aTrocaTurno:OPERACAO == 3 .OR. aTrocaTurno:OPERACAO == 4

		If !U_RegExiste("SR6",xFilial("SR6",aTrocaTurno:PF_FILIAL) + aTrocaTurno:PF_TURNODE, 1)
			cMsg := "PF_TURNODE inv�lido"
			nRetorno := 3 //Erro
			Return nRetorno
		EndIf                                                                                                            

		If !NaoVazio(aTrocaTurno:PF_SEQUEDE)
			cMsg := "A Sequencia (PF_SEQUEDE) dever� ser informada!"
			nRetorno := 3 //Erro
			Return nRetorno
		EndIf

		/*if !U_RegExiste("SPJ", aTrocaTurno:PF_FILIAL + aTrocaTurno:PF_TURNODE + aTrocaTurno:PF_SEQUEDE, 1)   
			cMsg := "Sequencia (PF_SEQUEDE): " + AllTrim(aTrocaTurno:PF_SEQUEDE) + " n�o cadastrada para o Turno (PF_TURNODE): " + AllTrim(aTrocaTurno:PF_TURNODE)
			nRetorno := 3 //Erro
			Return nRetorno
		endif*/                                                                                               

		If !NaoVazio(aTrocaTurno:PF_REGRADE)
			cMsg := "A Regra (PF_REGRADE) dever� ser informada!"
			nRetorno := 3 //Erro
			Return nRetorno
		EndIf

		If !U_RegExiste("SPA",xFilial("SPA",aTrocaTurno:PF_FILIAL) + aTrocaTurno:PF_REGRADE, 1)
			cMsg := "PF_REGRADE inv�lido"
			nRetorno := 3 //Erro
			Return nRetorno
		EndIf

		If !U_RegExiste("SR6",xFilial("SR6",aTrocaTurno:PF_FILIAL) + aTrocaTurno:PF_TURNOPA, 1)
			cMsg := "PF_TURNOPA inv�lido"
			nRetorno := 3 //Erro
			Return nRetorno
		Endif                                                                                                                 

		If !NaoVazio(aTrocaTurno:PF_SEQUEPA)
			cMsg := "A Sequencia (PF_SEQUEPA) dever� ser informada!"
			nRetorno := 3 //Erro
			Return nRetorno
		EndIf
	
		/*if !U_RegExiste("SPJ", aTrocaTurno:PF_FILIAL + aTrocaTurno:PF_TURNOPA + aTrocaTurno:PF_SEQUEPA, 1)   
			cMsg := "Sequencia (PF_SEQUEPA): " + AllTrim(aTrocaTurno:PF_SEQUEPA) + " n�o cadastrada para o Turno (PF_TURNOPA): " + AllTrim(aTrocaTurno:PF_TURNOPA)
			nRetorno := 3 //Erro
			Return nRetorno
		endif*/                                                                                                                                                                                              

		If !NaoVazio(aTrocaTurno:PF_REGRAPA)
			cMsg := "A Regra (PF_REGRAPA) dever� ser informada!"
			nRetorno := 3 //Erro
			Return nRetorno
		EndIf

		If !U_RegExiste("SPA",xFilial("SPA",aTrocaTurno:PF_FILIAL) + aTrocaTurno:PF_REGRAPA, 1)
			cMsg := "PF_REGRAPA inv�lido"
			nRetorno := 3 //Erro
			Return nRetorno
		EndIf

	EndIf
Return (nRetorno)
