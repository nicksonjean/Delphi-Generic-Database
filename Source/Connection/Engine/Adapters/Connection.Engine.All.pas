{
  Connection.Engine.All
  ------------------------------------------------------------------------------
  Objetivo : Agrega as quatro engines (dbExpress, FireDAC, ZeOS, UniDAC) via os
             agregadores Connection.*.All — um único `uses Connection.Engine.All` registra
             todas no EngineRegistry (cada Factory faz isso em initialization).
  Nota     : Não declara tipos próprios — apenas força o linkage das dependências.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Engine.All;

interface

uses
  Connection.dbExpress.All,
  Connection.FireDAC.All,
  Connection.ZeOS.All,
  Connection.UniDAC.All;

implementation

end.
