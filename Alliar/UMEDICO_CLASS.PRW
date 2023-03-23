#Include 'Protheus.ch'



/*/{Protheus.doc} uMEDICO
Medicos
@author Augusto Ribeiro (www.compila.com.br)
@since 01/06/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
class uMEDICO 
	
	DATA NOME                AS STRING
	DATA CRM                 AS STRING
	DATA UFCRM               AS STRING
	DATA CPF                 AS STRING
	DATA ENDERECO            AS STRING
	DATA COMPLEMENTO         AS STRING
	DATA CODMUN              AS STRING
	DATA BAIRRO              AS STRING
	DATA MUNICIPIO           AS STRING
	DATA UF                  AS STRING
	DATA CEP                 AS STRING
	DATA DDI1                AS STRING
	DATA DDD1                AS STRING
	DATA TEL1                AS STRING
	DATA EMAIL1              AS STRING
	DATA DTNASC              AS DATE 
	DATA ESPECIALIDADE1      AS STRING
	DATA ESPECIALIDADE2      AS STRING
	DATA ESPECIALIDADE3      AS STRING
	DATA TEL2                AS STRING
	DATA CEL1                AS STRING
	DATA CEL2                AS STRING
	DATA TELCOM1             AS STRING
	DATA TELCOM2             AS STRING
	DATA EMAIL2              AS STRING
	DATA CONVENIO            AS STRING
	DATA CLINICA             AS STRING


	method new() constructor 

endclass

/*/{Protheus.doc} new
Metodo construtor
@author Augusto Ribeiro (www.compila.com.br)
@since 01/06/2017 
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
method new() class uMEDICO
	
	SELF:NOME             := "" 
	SELF:CRM              := "" 
	SELF:UFCRM            := "" 
	SELF:CPF              := "" 
	SELF:ENDERECO         := "" 
	SELF:COMPLEMENTO      := "" 
	SELF:CODMUN           := "" 
	SELF:BAIRRO           := "" 
	SELF:MUNICIPIO        := "" 
	SELF:UF               := "" 
	SELF:CEP              := "" 
	SELF:DDI1             := "" 
	SELF:DDD1             := "" 
	SELF:TEL1             := "" 
	SELF:EMAIL1           := "" 
	//SELF:DTNASC           := CTOD("  /  /  ") 
	SELF:ESPECIALIDADE1   := "" 
	SELF:ESPECIALIDADE2   := "" 
	SELF:ESPECIALIDADE3   := "" 
	SELF:TEL2             := "" 
	SELF:CEL1             := "" 
	SELF:CEL2             := "" 
	SELF:TELCOM1          := "" 
	SELF:TELCOM2          := "" 
	SELF:EMAIL2           := "" 
	SELF:CONVENIO         := ""
	SELF:CLINICA          := ""

return

