#Include "Protheus.Ch"



/*/{Protheus.doc} F430GRAFIL
Ponto de entrada para gravar na tabela fig a filial pertecente ao cnpj da linha header contido do arquivo .ret		
@author Augusto Ribeiro | www.compila.com.br
@since 23/04/2018
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function F430GRAFIL()
Local aParam	:= PARAMIXB



/*------------------------------------------------------ Augusto Ribeiro | 23/04/2018 - 3:27:14 PM
	Ponto de entrada utilizado para exclir registro duplicado, já que não existe
	ponto de entrada para validar a inclusão de novos registros e o Protheus
	não realiza nenhuma validação antes da inclusão
------------------------------------------------------------------------------------------*/
DelDuplic()

Return()



/*/{Protheus.doc} DelDuplic
Exclusao de duplicadades.
@author Augusto Ribeiro | www.compila.com.br
@since 23/04/2018
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function DelDuplic()
Local aAreaFIG	:= FIG->(GETAREA())


DBSELECTAREA("FIG")
nRecFIG		:= FIG->(RECNO())
cCodBar		:= FIG->FIG_CODBAR

FIG->(DbOrderNickName("CODBAR"))

IF FIG->(DBSEEK(cCodBar))

	WHILE FIG->FIG_CODBAR == cCodBar
		
		IF nRecFIG <> FIG->(RECNO())
			//| Exclui o registro recem inserido para evitar duplicadades |
			FIG->(DBGOTO(nRecFIG))
			reclock("FIG",.F.)
				FIG->(DBDELETE())
			MSUNLOCK()
			EXIT
		ENDIF
	
		FIG->(DBSKIP())
	ENDDO
	
ENDIF 



RestArea(aAreaFIG)

Return()





