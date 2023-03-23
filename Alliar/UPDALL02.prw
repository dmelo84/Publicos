#Include 'Protheus.ch'

#define UPDVERSAO 02
//---------------------------------------------------------------------
/*/{Protheus.doc} UPDALL02
Atualiza dicionários 
@author Maria Elisandra de Paula
@since 03/12/2015
@version P12
@return nil
/*/
//---------------------------------------------------------------------

User Function UPDALL02()
	
	Local cModulo := "MNT"
	Local bPrepar := {|| fUpdIni() }
	Local nVersao := UPDVERSAO
	
	NGCriaUpd(cModulo,bPrepar,nVersao)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fUpdIni
Carrega variáveis para alteração do dicionário.
@author Maria Elisandra de Paula 
@since 03/12/2015
@version MP12
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fUpdIni()
	Local nOrdem
		
	aSX2 		:= {}
	aSX3 		:= {}
	aHelp		:= {}
	aSx3Alter	:= {}
	aSX7 		:= {}
	aSX6 		:= {}
	aSX9		:= {}
	aSXB		:= {}
	
	//-------------------------------TABELAS------------------------------
	aAdd(aSX2,{'ZNA','','Plano por empresas','Plano por empresas','Plano por empresas','C','ZNA_FILIAL+ZNA_CODIGO','C','C'})
	aAdd(aSX2,{"STI"})
	aAdd(aSX2,{"STJ"})
		
	//-------------------------------ÍNDICES------------------------------
	aAdd(aSix,{'ZNA','1','ZNA_FILIAL+ZNA_CODIGO+DTOS(ZNA_DTPLAN)','Código+Data Plano','','','U','N'})
   	  
    //-------------------------------CAMPOS------------------------------
   
	aAdd(aSX3,{'ZNA',Nil,'ZNA_FILIAL','C',,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'Filial','Filial','Filial',; //Tit. Port.,Tit.Esp.,Tit.Ing. 
			'Filial do Sistema','Filial do Sistema','Filial do Sistema',;
			'@!',;//Picture
			'',;//Valid
			X3_NAOUSADO_USADO,;//Usado
			'',;//Relacao
			'',1,X3_NAOUSADO_RESERV,'','',;//F3,Nivel,Reserv,Check,Trigger
			'U','N',' ',' ',' ',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','','033','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra

	aAdd(aSX3,{'ZNA',Nil,'ZNA_CODIGO','C',6,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'Código','Código','Código',; //Tit. Port.,Tit.Esp.,Tit.Ing.//
			'Código do plano','Código do plano','Código do plano',;//Desc. Port.,Desc.Esp.,Desc.Ing.//
			'@!',;//Picture
			'',;//Valid
			X3_EMUSO_USADO,;//Usado
			'GETSXENUM("ZNA","ZNA_CODIGO")',;//Relacao
			'',0,X3_OBRIGAT_RESERV,'','',;//F3,Nivel,Reserv,Check,Trigger
			'U','S','V','R','',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','N','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra	
			
			

  	aAdd(aSX3,{'ZNA',Nil,'ZNA_USUARI','C',25,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'Usu. Resp.','Usu. Resp.','Usu. Resp.',; //Tit. Port.,Tit.Esp.,Tit.Ing.//
			'Usuario Responsavel Plano','Usuario Responsavel Plano','Usuario Responsavel Plano',;//Desc. Port.,Desc.Esp.,Desc.Ing.//
			'@!',;//Picture
			'',;//Valid
			X3_EMUSO_USADO,;//Usado
			'cUsername',;//Relacao
			'',0,X3_OBRIGAT_RESERV,'','S',;//F3,Nivel,Reserv,Check,Trigger
			'U','S','V','R','',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra
		
	aAdd(aSX3,{'ZNA',Nil,'ZNA_DTPLAN','D',8,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'Data Plano','Data Plano','Data Plano',; //Tit. Port.,Tit.Esp.,Tit.Ing.//
			'Data do Plano Manutencao','Data do Plano Manutencao','Data do Plano Manutencao',;//Desc. Port.,Desc.Esp.,Desc.Ing.//
			'99/99/9999',;//Picture
			'NaoVazio()',;//Valid
			X3_EMUSO_USADO,;//Usado
			'IF(INCLUI,DDATABASE,ZNA->ZNA_DTPLAN)',;//Relacao
			'',0,X3_OBRIGAT_RESERV,'','',;//F3,Nivel,Reserv,Check,Trigger
			'U','S','A','R','',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','N','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra	

	aAdd(aSX3,{'ZNA',Nil,'ZNA_DESCRI','C',40,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
            'Descrição','Descrição','Descrição',; //Tit. Port.,Tit.Esp.,Tit.Ing. 
            'Descrição do Plano','Descrição do Plano','Descrição do Plano',;//Desc. Port.,Desc.Esp.,Desc.Ing.
            '@!',;//Picture
            '',;//Valid
            X3_EMUSO_USADO,;//Usado
            '',;//Relacao
            '',1,X3_OBRIGAT_RESERV,'','N',;//F3,Nivel,Reserv,Check,Trigger
            'U','S','A','R','',;//Propri,Browse,Visual,Context,Obrigat
            '',;    //VldUser
            '','','',;//Box Port.,Box Esp.,Box Ing.
            '','','N','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
            'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra
	
	aAdd(aSX3,{'ZNA',Nil,'ZNA_DTINI','D',8,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'Data Início','Data Início','Data Início',; //Tit. Port.,Tit.Esp.,Tit.Ing.//
			'Data Início do Plano','Data Início do Plano','Data Início do Plano',;//Desc. Port.,Desc.Esp.,Desc.Ing.//
			'99/99/9999',;//Picture
			'NaoVazio() .And. If(Empty(M->ZNA_DTFIM),.t.,M->ZNA_DTINI <= M->ZNA_DTFIM)',;//Valid
			X3_EMUSO_USADO,;//Usado
			'IF(INCLUI,DDATABASE,ZNA->ZNA_DTINI)',;//Relacao
			'',0,X3_USADO_RESERV,'','',;//F3,Nivel,Reserv,Check,Trigger
			'U','S','A','R','',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','N','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra	
			
	aAdd(aSX3,{'ZNA',Nil,'ZNA_DTFIM','D',8,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'Data Fim','Data Fim','Data Fim',; //Tit. Port.,Tit.Esp.,Tit.Ing.//
			'Data Fim do Plano','Data Fim do Plano','Data Fim do Plano',;//Desc. Port.,Desc.Esp.,Desc.Ing.//
			'99/99/9999',;//Picture
			'NaoVazio() .And. VALDATA(M->ZNA_DTINI,M->ZNA_DTFIM,"DATAINVALI")',;//Valid
			X3_EMUSO_USADO,;//Usado
			'IF(INCLUI,DDATABASE,ZNA->ZNA_DTFIM)',;//Relacao
			'',0,X3_USADO_RESERV,'','',;//F3,Nivel,Reserv,Check,Trigger
			'U','S','A','R','',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','N','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra			
 
aAdd(aSX3,{'ZNA',Nil,'ZNA_EMPINI','C',2 + FwSizeFilial(),0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'Emp. Inicial','Emp. Inicial','Emp. Inicial',; //Tit. Port.,Tit.Esp.,Tit.Ing.//
			'Empresa Inicial','Empresa Inicial','Empresa Inicial',;//Desc. Port.,Desc.Esp.,Desc.Ing.//
			'@!',;//Picture
			'U_ALL1AVAL(1,M->ZNA_EMPINI,M->ZNA_EMPFIM,"SM0")',;//Valid
			X3_EMUSO_USADO,;//Usado
			'',;//Relacao
			'EMP',0,X3_USADO_RESERV,'','S',;//F3,Nivel,Reserv,Check,Trigger
			'U','N','A','R','',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','N','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra	
  
    aAdd(aSX3, {'ZNA',Nil,'ZNA_DEMPIN','C',60,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
            'Nome Emp Ini','Nome Emp Ini','Nome Emp Ini',; //Tit. Port.,Tit.Esp.,Tit.Ing. 
            'Nome Empresa Inicial','Nome Empresa Inicial','Nome Empresa Inicial',;//Desc. Port.,Desc.Esp.,Desc.Ing.
            '@!',;//Picture
            '',;//Valid
            X3_EMUSO_USADO,;//Usado
            '',;//Relacao
            '',1,X3_USADO_RESERV,'','N',;//F3,Nivel,Reserv,Check,Trigger
            'U','N','V','V','',;//Propri,Browse,Visual,Context,Obrigat
            '',;    //VldUser
            '','','',;//Box Port.,Box Esp.,Box Ing.
            '','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
            '','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra
            
	aAdd(aSX3,{'ZNA',Nil,'ZNA_EMPFIM','C',2 + FwSizeFilial(),0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'Emp. Final','Emp. Final','Emp. Final',; //Tit. Port.,Tit.Esp.,Tit.Ing.//
			'Empresa Final','Empresa Final','Empresa Final',;//Desc. Port.,Desc.Esp.,Desc.Ing.//
			'@!',;//Picture
			'U_ALL1AVAL(2,M->ZNA_EMPINI,M->ZNA_EMPFIM,"SM0")',;//Valid
			X3_EMUSO_USADO,;//Usado
			'IF(INCLUI,REPLICATE("Z",Len(ZNA->ZNA_EMPFIM)),ZNA->ZNA_EMPFIM)',;//Relacao
			'EMP',0,X3_USADO_RESERV,'','S',;//F3,Nivel,Reserv,Check,Trigger
			'U','N','A','R','',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','N','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra			
    
	aAdd(aSX3, {'ZNA',Nil,'ZNA_DEMPFI','C',60,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
            'Nome Emp Fim','Nome Emp Fim','Nome Emp Fim',; //Tit. Port.,Tit.Esp.,Tit.Ing. 
            'Nome Empresa Final','Nome Empresa Final','Nome Empresa Final',;//Desc. Port.,Desc.Esp.,Desc.Ing.
            '@!',;//Picture
            '',;//Valid
            X3_EMUSO_USADO,;//Usado
            '',;//Relacao
            '',1,X3_USADO_RESERV,'','N',;//F3,Nivel,Reserv,Check,Trigger
            'U','N','V','V','',;//Propri,Browse,Visual,Context,Obrigat
            '',;    //VldUser
            '','','',;//Box Port.,Box Esp.,Box Ing.
            '','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
            '','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra
                         
	aAdd(aSX3,{'ZNA',Nil,'ZNA_BEMINI','C',TAMSX3("T9_CODBEM")[1],0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'Bem Início','Bem Início','Bem Início',; //Tit. Port.,Tit.Esp.,Tit.Ing.//
			'Limite Inferior do Bem','Limite Inferior do Bem','Limite Inferior do Bem',;//Desc. Port.,Desc.Esp.,Desc.Ing.//
			'@!',;//Picture
			'U_ALL1AVAL(1,M->ZNA_BEMINI,M->ZNA_BEMFIM,"ST9")',;//Valid
			X3_EMUSO_USADO,;//Usado
			'',;//Relacao
			'XALL1',0,X3_USADO_RESERV,'','S',;//F3,Nivel,Reserv,Check,Trigger
			'U','N','A','R','',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra
	
	aAdd(aSX3, {'ZNA',Nil,'ZNA_DBEMIN','C',40,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
            'Nome Bem Ini','Nome Bem Ini','Nome Bem Ini',; //Tit. Port.,Tit.Esp.,Tit.Ing. 
            'Nome Bem Inicial','Nome Bem Inicial','Nome Bem Inicial',;//Desc. Port.,Desc.Esp.,Desc.Ing.
            '@!',;//Picture
            '',;//Valid
            X3_EMUSO_USADO,;//Usado
            '',;//Relacao
            '',1,X3_USADO_RESERV,'','N',;//F3,Nivel,Reserv,Check,Trigger
            'U','N','V','V','',;//Propri,Browse,Visual,Context,Obrigat
            '',;    //VldUser
            '','','',;//Box Port.,Box Esp.,Box Ing.
            '','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
            '','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra	
	
	
	aAdd(aSX3,{'ZNA',Nil,'ZNA_BEMFIM','C',TAMSX3("T9_CODBEM")[1],0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'Bem Fim','Bem Fim','Bem Fim',; //Tit. Port.,Tit.Esp.,Tit.Ing.//
			'Limite Superior do Bem','Limite Superior do Bem','Limite Superior do Bem',;//Desc. Port.,Desc.Esp.,Desc.Ing.//
			'@!',;//Picture
			'U_ALL1AVAL(2,M->ZNA_BEMINI,M->ZNA_BEMFIM,"ST9")',;//Valid
			X3_EMUSO_USADO,;//Usado
			'If(INCLUI,Replicate("Z",Len(ZNA->ZNA_BEMFIM)),ZNA->ZNA_BEMFIM)',;//Relacao
			'XALL1',0,X3_USADO_RESERV,'','S',;//F3,Nivel,Reserv,Check,Trigger
			'U','N','A','R','',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra
  
  	aAdd(aSX3, {'ZNA',Nil,'ZNA_DBEMFI','C',40,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
            'Nome Bem Fim','Nome Bem Fim','Nome Bem Fim',; //Tit. Port.,Tit.Esp.,Tit.Ing. 
            'Nome Bem Final','Nome Bem Final','Nome Bem Final',;//Desc. Port.,Desc.Esp.,Desc.Ing.
            '@!',;//Picture
            '',;//Valid
            X3_EMUSO_USADO,;//Usado
            '',;//Relacao
            '',1,X3_USADO_RESERV,'','N',;//F3,Nivel,Reserv,Check,Trigger
            'U','N','V','V','',;//Propri,Browse,Visual,Context,Obrigat
            '',;    //VldUser
            '','','',;//Box Port.,Box Esp.,Box Ing.
            '','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
            '','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra	
  
  	aAdd(aSX3,{'ZNA',Nil,'ZNA_SERINI','C',TAMSX3("T4_SERVICO")[1],0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'Serv. Inicio','Serv. Inicio','Serv. Inicio',; //Tit. Port.,Tit.Esp.,Tit.Ing.//
			'Servico Inicio','Servico Inicio','Servico Inicio',;//Desc. Port.,Desc.Esp.,Desc.Ing.//
			'@!',;//Picture
			'U_ALL1AVAL(1,M->ZNA_SERINI,M->ZNA_SERFIM,"ST4")',;//
			X3_EMUSO_USADO,;//Usado
			'',;//Relacao
			'ST4',0,X3_USADO_RESERV,'','S',;//F3,Nivel,Reserv,Check,Trigger
			'U','N','A','R','',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra

  	aAdd(aSX3, {'ZNA',Nil,'ZNA_DSERIN','C',40,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
            'Nome Ser Ini','Nome Ser Ini','Nome Ser Ini',; //Tit. Port.,Tit.Esp.,Tit.Ing. 
            'Nome Serviço Inicial','Nome Serviço Inicial','Nome Serviço Inicial',;//Desc. Port.,Desc.Esp.,Desc.Ing.
            '@!',;//Picture
            '',;//Valid
            X3_EMUSO_USADO,;//Usado
            '',;//Relacao
            '',1,X3_USADO_RESERV,'','N',;//F3,Nivel,Reserv,Check,Trigger
            'U','N','V','V','',;//Propri,Browse,Visual,Context,Obrigat
            '',;    //VldUser
            '','','',;//Box Port.,Box Esp.,Box Ing.
            '','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
            '','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra	

		
  	aAdd(aSX3,{'ZNA',Nil,'ZNA_SERFIM','C',TAMSX3("T4_SERVICO")[1],0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'Servico Fim ','Servico Fim ','Servico Fim ',; //Tit. Port.,Tit.Esp.,Tit.Ing.//
			'Servico Fim','Servico Fim','Servico Fim',;//Desc. Port.,Desc.Esp.,Desc.Ing.//
			'@!',;//Picture
			'U_ALL1AVAL(2,M->ZNA_SERINI,M->ZNA_SERFIM,"ST4")',;//Valid
			X3_EMUSO_USADO,;//Usado
			'IF(INCLUI,REPLICATE("Z",Len(ZNA->ZNA_SERFIM)),ZNA->ZNA_SERFIM)',;//Relacao
			'ST4',0,X3_USADO_RESERV,'','S',;//F3,Nivel,Reserv,Check,Trigger
			'U','N','A','R','',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra			

  	aAdd(aSX3, {'ZNA',Nil,'ZNA_DSERFI','C',40,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
            'Nome Ser Fim','Nome Ser Fim','Nome Ser Fim',; //Tit. Port.,Tit.Esp.,Tit.Ing. 
            'Nome Serviço Final','Nome Serviço Final','Nome Serviço Final',;//Desc. Port.,Desc.Esp.,Desc.Ing.
            '@!',;//Picture
            '',;//Valid
            X3_EMUSO_USADO,;//Usado
            '',;//Relacao
            '',1,X3_USADO_RESERV,'','N',;//F3,Nivel,Reserv,Check,Trigger
            'U','N','V','V','',;//Propri,Browse,Visual,Context,Obrigat
            '',;    //VldUser
            '','','',;//Box Port.,Box Esp.,Box Ing.
            '','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
            '','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra	

   
   	aAdd(aSX3,{'ZNA',Nil,'ZNA_FAMINI','C',TAMSX3("T6_CODFAMI")[1],0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'Famil. Inic.','Famil. Inic.','Famil. Inic.',; //Tit. Port.,Tit.Esp.,Tit.Ing.//
			'Codigo da Familia Inicio ','Codigo da Familia Inicio ','Codigo da Familia Inicio ',;//Desc. Port.,Desc.Esp.,Desc.Ing.//
			'@!',;//Picture
			'U_ALL1AVAL(1,M->ZNA_FAMINI,M->ZNA_FAMFIM,"ST6")',;//
			X3_EMUSO_USADO,;//Usado
			'',;//Relacao
			'ST6',0,X3_USADO_RESERV,'','S',;//F3,Nivel,Reserv,Check,Trigger
			'U','N','A','R','',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra
	
	aAdd(aSX3, {'ZNA',Nil,'ZNA_DFAMIN','C',40,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
            'Nome Fam Ini','Nome Fam Ini','Nome Fam Ini',; //Tit. Port.,Tit.Esp.,Tit.Ing. 
            'Nome Família Inicial','Nome Família Inicial','Nome Família Inicial',;//Desc. Port.,Desc.Esp.,Desc.Ing.
            '@!',;//Picture
            '',;//Valid
            X3_EMUSO_USADO,;//Usado
            '',;//Relacao
            '',1,X3_USADO_RESERV,'','N',;//F3,Nivel,Reserv,Check,Trigger
            'U','N','V','V','',;//Propri,Browse,Visual,Context,Obrigat
            '',;    //VldUser
            '','','',;//Box Port.,Box Esp.,Box Ing.
            '','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
            '','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra	
			
   	aAdd(aSX3,{'ZNA',Nil,'ZNA_FAMFIM','C',TAMSX3("T6_CODFAMI")[1],0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'Familia Fim ','Familia Fim ','Familia Fim ',; //Tit. Port.,Tit.Esp.,Tit.Ing.//
			'Codigo da Familia Fim','Codigo da Familia Fim','Codigo da Familia Fim',;//Desc. Port.,Desc.Esp.,Desc.Ing.//
			'@!',;//Picture
			'U_ALL1AVAL(2,M->ZNA_FAMINI,M->ZNA_FAMFIM,"ST6")',;//Valid
			X3_EMUSO_USADO,;//Usado
			'IF(INCLUI,REPLICATE("Z",Len(ZNA->ZNA_FAMFIM)),ZNA->ZNA_FAMFIM)',;//Relacao
			'ST6',0,X3_USADO_RESERV,'','S',;//F3,Nivel,Reserv,Check,Trigger
			'U','N','A','R','',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra		
  
	aAdd(aSX3, {'ZNA',Nil,'ZNA_DFAMFI','C',40,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
            'Nome Fam Fim','Nome Fam Fim','Nome Fam Fim',; //Tit. Port.,Tit.Esp.,Tit.Ing. 
            'Nome Família Final','Nome Família Final','Nome Família Final',;//Desc. Port.,Desc.Esp.,Desc.Ing.
            '@!',;//Picture
            '',;//Valid
            X3_EMUSO_USADO,;//Usado
            '',;//Relacao
            '',1,X3_USADO_RESERV,'','N',;//F3,Nivel,Reserv,Check,Trigger
            'U','N','V','V','',;//Propri,Browse,Visual,Context,Obrigat
            '',;    //VldUser
            '','','',;//Box Port.,Box Esp.,Box Ing.
            '','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
            '','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra	
  
  
     aAdd(aSX3,{'ZNA',Nil,'ZNA_MODINI','C',TAMSX3("TQR_TIPMOD")[1],0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'De Tipo Mod.','De Tipo Mod.','De Tipo Mod.',; //Tit. Port.,Tit.Esp.,Tit.Ing.//
			'De Tipo do Modelo','De Tipo do Modelo','De Tipo do Modelo',;//Desc. Port.,Desc.Esp.,Desc.Ing.//
			'@!',;//Picture
			'U_ALL1AVAL(1,M->ZNA_MODINI,M->ZNA_MODFIM,"TQR")',;//
			X3_EMUSO_USADO,;//Usado
			'',;//Relacao
			'TQR',0,X3_USADO_RESERV,'','S',;//F3,Nivel,Reserv,Check,Trigger
			'U','N','A','R','',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra
  
  	aAdd(aSX3, {'ZNA',Nil,'ZNA_DMODIN','C',40,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
            'Nome Tip Ini','Nome Tip Ini','Nome Tip Ini',; //Tit. Port.,Tit.Esp.,Tit.Ing. 
            'Nome Tipo Modelo Inicial','Nome Tipo Modelo Inicial','Nome Tipo Modelo Inicial',;//Desc. Port.,Desc.Esp.,Desc.Ing.
            '@!',;//Picture
            '',;//Valid
            X3_EMUSO_USADO,;//Usado
            '',;//Relacao
            '',1,X3_USADO_RESERV,'','N',;//F3,Nivel,Reserv,Check,Trigger
            'U','N','V','V','',;//Propri,Browse,Visual,Context,Obrigat
            '',;    //VldUser
            '','','',;//Box Port.,Box Esp.,Box Ing.
            '','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
            '','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra
  
  
     aAdd(aSX3,{'ZNA',Nil,'ZNA_MODFIM','C',TAMSX3("TQR_TIPMOD")[1],0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'Até Tipo','Até Tipo','Até Tipo',; //Tit. Port.,Tit.Esp.,Tit.Ing.//
			'Ate Tipo do Modelo','Ate Tipo do Modelo','Ate Tipo do Modelo',;//Desc. Port.,Desc.Esp.,Desc.Ing.//
			'@!',;//Picture
			'U_ALL1AVAL(2,M->ZNA_MODINI,M->ZNA_MODFIM,"TQR")',;//Valid
			X3_EMUSO_USADO,;//Usado
			'IF(INCLUI,REPLICATE("Z",Len(ZNA->ZNA_MODFIM)),ZNA->ZNA_MODFIM)',;//Relacao
			'TQR',0,X3_USADO_RESERV,'','S',;//F3,Nivel,Reserv,Check,Trigger
			'U','N','A','R','',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra

	aAdd(aSX3, {'ZNA',Nil,'ZNA_DMODFI','C',40,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
            'Nome Tip Fim','Nome Tip Fim','Nome Tip Fim',; //Tit. Port.,Tit.Esp.,Tit.Ing. 
            'Nome Tipo Modelo Final','Nome Tipo Modelo Final','Nome Tipo Modelo Final',;//Desc. Port.,Desc.Esp.,Desc.Ing.
            '@!',;//Picture
            '',;//Valid
            X3_EMUSO_USADO,;//Usado
            '',;//Relacao
            '',1,X3_USADO_RESERV,'','N',;//F3,Nivel,Reserv,Check,Trigger
            'U','N','V','V','',;//Propri,Browse,Visual,Context,Obrigat
            '',;    //VldUser
            '','','',;//Box Port.,Box Esp.,Box Ing.
            '','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
            '','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra	

	//---------------------------------------------------------------------
	
	aAdd(aSX3,{'STI',Nil,'TI_XCODZNA','C',6,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'Código ZNA','Código ZNA','Codigo ZNA',; //Tit. Port.,Tit.Esp.,Tit.Ing.//
			'Código da Tabela ZNA','Código da Tabela ZNA','Código da Tabela ZNA',;//Desc. Port.,Desc.Esp.,Desc.Ing.//
			'@!',;//Picture
			'',;//Valid
			X3_EMUSO_USADO,;//Usado
			'',;//Relacao
			'',0,X3_NAOUSADO_RESERV,'','',;//F3,Nivel,Reserv,Check,Trigger
			'U','N','V','R','',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','N','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra	

	aAdd(aSX3,{'STJ',Nil,'TJ_XDATALT','C',1,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
		'Dt.Alterada','Dt.Alterada','Dt.Alterada',; //Tit. Port.,Tit.Esp.,Tit.Ing. 
		'Data Alterada','Data Alterada','Data Alterada',;//Desc. Port.,Desc.Esp.,Desc.Ing.
		'@!',;//Picture
		'',;//Valid
		X3_EMUSO_USADO,;//Usado
		'IF(INCLUI,"2",STJ->TJ_XDATALT)',;//Relacao
		'',2,X3_USADO_RESERV,'','N',;//F3,Nivel,Reserv,Check,Trigger
		'U','N','V','R','',;//Propri,Browse,Visual,Context,Obrigat
		'',;	//VldUser
		'1=Sim;2=Não','','',;//Box Port.,Box Esp.,Box Ing.
		'','','','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
		'','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra   
  
	aAdd(aSX3,{'STJ',Nil,'TJ_XDTINIC','D',8,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'Dt.Inic.Ant.','Dt.Inic.Ant.','Dt.Inic.Ant.',; //Tit. Port.,Tit.Esp.,Tit.Ing.//
			'Data Inicial Anterior','Data Inicial Anterior','Data Inicial Anterior',;//Desc. Port.,Desc.Esp.,Desc.Ing.//
			'99/99/9999',;//Picture
			'',;//Valid
			X3_EMUSO_USADO,;//Usado
			'',;//Relacao
			'',0,X3_NAOUSADO_RESERV,'','',;//F3,Nivel,Reserv,Check,Trigger
			'U','N','V','R','',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','N','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra	

 	aAdd(aSX3,{'STJ',Nil,'TJ_XDTFIM','D',8,0,; //Alias,Ordem,Campo,Tipo,Tamanho,Decimais
			'Data Plano','Data Plano','Data Plano',; //Tit. Port.,Tit.Esp.,Tit.Ing.//
			'Data Final Anterior','Data Final Anterior','Data Final Anterior',;//Desc. Port.,Desc.Esp.,Desc.Ing.//
			'99/99/9999',;//Picture
			'',;//Valid
			X3_EMUSO_USADO,;//Usado
			'',;//Relacao
			'',0,X3_NAOUSADO_RESERV,'','',;//F3,Nivel,Reserv,Check,Trigger
			'U','N','V','R','',;//Propri,Browse,Visual,Context,Obrigat
			'',;	//VldUser
			'','','',;//Box Port.,Box Esp.,Box Ing.
			'','','N','','',; //PictVar,When,Ini BRW,GRP SXG,Folder
			'N','','','',' ',' '}) //Pyme,CondSQL,ChkSQL,IdxSrv,Ortogra	
 
    //-------------------------------GATILHOS------------------------------                 
	
	AADD(aSx7,{"ZNA_EMPINI","001","SM0->M0_NOMECOM","ZNA_DEMPIN","P","S","SM0",1,'M->ZNA_EMPINI'," ","S"})
	AADD(aSx7,{"ZNA_EMPFIM","001","SM0->M0_NOMECOM","ZNA_DEMPFI","P","S","SM0",1,'M->ZNA_EMPFIM'," ","S"})
	AADD(aSx7,{"ZNA_BEMINI","001",'U_ALLNOME("ST9",M->ZNA_BEMINI)',"ZNA_DBEMIN","P","N","",1,''," ","S"})
    AADD(aSx7,{"ZNA_BEMFIM","001",'U_ALLNOME("ST9",M->ZNA_BEMFIM)',"ZNA_DBEMFI","P","N","",1,''," ","S"})
    AADD(aSx7,{"ZNA_SERINI","001",'U_ALLNOME("ST4",M->ZNA_SERINI)',"ZNA_DSERIN","P","N","",1,''," ","S"})
    AADD(aSx7,{"ZNA_SERFIM","001",'U_ALLNOME("ST4",M->ZNA_SERFIM)',"ZNA_DSERFI","P","N","",1,''," ","S"})
    AADD(aSx7,{"ZNA_FAMINI","001",'U_ALLNOME("ST6",M->ZNA_FAMINI)',"ZNA_DFAMIN","P","N","",1,''," ","S"})
    AADD(aSx7,{"ZNA_FAMFIM","001",'U_ALLNOME("ST6",M->ZNA_FAMFIM)',"ZNA_DFAMFI","P","N","",1,''," ","S"})
    
    AADD(aSx7,{"ZNA_MODINI","001",'U_ALLNOME("TQR",M->ZNA_MODINI)',"ZNA_DMODIN","P","N","",1,''," ","S"})
    AADD(aSx7,{"ZNA_MODFIM","001",'U_ALLNOME("TQR",M->ZNA_MODFIM)',"ZNA_DMODFI","P","N","",1,''," ","S"})
    
    //-------------------------------HELPS------------------------------
	aAdd(aHelp,{'ZNA_DTPLAN' ,'Data em que o plano de manutenção foi executado.'})
	aAdd(aHelp,{'ZNA_DESCRI' ,'Descrição suscinta do plano. Serve para identificação complementar do plano.'})
	aAdd(aHelp,{'ZNA_DTINI' ,"Limite inferior de seleção das manutenções a serem consideradas pelo plano. O sistema utilizará esta informação para a seleção dos Bens conforme a sua data de próxima manutenção." })
	aAdd(aHelp,{'ZNA_DTFIM' ,'Limite superior de data de manutenção do plano. Os Bens com data de próxima manutenção entre a data inicio do plano e a data fim, serão considerados para o plano.'})
	aAdd(aHelp,{'ZNA_EMPINI','Limite inferior de seleção dos bens para o plano conforme a Empresa/Unid./Filial a que pertence o bem. Para selecionar todos os Bens, deixar este campo em branco.' })
	aAdd(aHelp,{'ZNA_EMPFIM','Limite superior de seleção dos bens para o plano conforme a Empresa/Unid./Filial a que pertence o bem. Para selecionar todos os Bens, preencher este campo com ZZZZZZ.' })
	aAdd(aHelp,{'ZNA_BEMINI','Limite inferior de seleção de Bem para o plano de manutenção. Para selecionar todos os bens, deixar este campo em branco.' })
	aAdd(aHelp,{'ZNA_BEMFIM','Limite superior de seleção de Bens para o plano de manutenção, por código de Bem. Para selecionar todos os Bens, preencher este campo com ZZZZZZ.' })
	aAdd(aHelp,{'ZNA_SERINI','Limite inferior de seleção dos Bens para o plano conforme o código de serviço de manutenção. Para selecionar todos os serviços, deixar este campo em branco.' })
	aAdd(aHelp,{'ZNA_SERFIM','Limite superior de seleção dos Bens para o plano conforme o código de serviço de manutenção. Para selecionar todos os serviços, preencher este campo com ZZZZZZ.' })
	aAdd(aHelp,{'ZNA_FAMINI','Limite inferior de seleção dos bens para o plano conforme a família a que pertence o bem. Para selecionar bens de todas as famílias, deixe este campo em branco.' })
	aAdd(aHelp,{'ZNA_FAMFIM','Limite superior de seleção dos bens para o plano conforme a família a que o bem pertence. Para selecionar bens de todas as famílias, preencha este campo com ZZZZZZ.' })
	aAdd(aHelp,{'ZNA_MODINI','Limite inferior de seleção dos bens para o plano conforme o código de tipo de modelo. Para selecionar bens de todos os tipos, deixe este campo em branco.' })
	aAdd(aHelp,{'ZNA_MODFIM','Limite superior de seleção dos bens para o plano conforme o código do tipo de modelo. Para selecionar bens de todos os tipos, preencha este campo com ZZZ.' })

	aAdd(aSXB,{"XALL1","1","01","RE","Consulta de Bens","Consulta de Bens","Consulta de Bens",""})
	aAdd(aSXB,{"XALL1","2","01","01","","",""	,"U_ALL001GN()"})
	aAdd(aSXB,{"XALL1","5","01","","","",""		,"If(!Empty(_CODRET), _CODRET, Space(TAMSX3('T9_CODBEM')[1]))"})
	
Return