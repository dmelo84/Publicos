USER FUNCTION L10RETNG()

aRet := ParamIXB[01]

aRet[01][01] := 1
aRet[02][01] := .T.
aRet[03][01] := 'ADM'
aRet[04][01] := DATE()
aRet[05][01] := 0
aRet[06][01] := 5
aRet[07][01] := 3
aRet[08][01] := 0
aRet[09][01] := .F. //-- Não mostra a janela de condição negociada.

Return aRet