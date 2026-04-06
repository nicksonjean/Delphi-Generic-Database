{
  Connection.Config.TOML.Mapper
  ------------------------------------------------------------------------------
  Objetivo : Mapeamento TOML (tabela raiz) → TConnection, sem JSON.
  Formato  : Chaves no nível raiz (engine, driver, …) e tabela aninhada [args].
  Requer   : DelphiTOML (unit TOML / TOML.Types).
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.TOML.Mapper;

interface

uses
  TOML,
  Connection;

type
  TConnectionConfigTomlMapper = class sealed
  public
    class function LoadFromTable(const ATable: TTOMLTable): TConnection;
  end;

implementation

uses
  System.SysUtils,
  TOML.Types,
  Connection.Types;

function TomlValueToText(const V: TTOMLValue; const AKey: string): string;
begin
  if V = nil then
    raise EArgumentException.CreateFmt('Connection config TOML: nil value for "%s".', [AKey]);
  case V.ValueType of
    tvtString:
      Result := TTOMLString(V).Value;
    tvtInteger:
      Result := IntToStr(TTOMLInteger(V).Value);
    tvtFloat:
      Result := FloatToStr(TTOMLFloat(V).Value);
    tvtBoolean:
      if TTOMLBoolean(V).Value then
        Result := 'True'
      else
        Result := 'False';
    tvtDateTime:
      Result := V.AsString;
  else
    raise EArgumentException.CreateFmt(
      'Connection config TOML: unsupported type for key "%s".', [AKey]);
  end;
end;

function TomlReadPort(const V: TTOMLValue; const AKey: string): Integer;
var
  S: string;
begin
  case V.ValueType of
    tvtInteger:
      Result := Integer(TTOMLInteger(V).Value);
    tvtFloat:
      Result := Trunc(TTOMLFloat(V).Value);
    tvtString:
      begin
        S := Trim(TTOMLString(V).Value);
        if not TryStrToInt(S, Result) then
          raise EArgumentException.CreateFmt(
            'Connection config TOML: "%s" must be an integer.', [AKey]);
      end;
  else
    raise EArgumentException.CreateFmt(
      'Connection config TOML: "%s" must be a number.', [AKey]);
  end;
end;

class function TConnectionConfigTomlMapper.LoadFromTable(const ATable: TTOMLTable): TConnection;
var
  V:         TTOMLValue;
  Engine:    TEngine;
  Driver:    TDriver;
  EngineStr: string;
  PortVal:   Integer;
  ArgsTbl:   TTOMLTable;
  I:         Integer;
  ArgKey:    string;
begin
  if not Assigned(ATable) then
    raise EArgumentException.Create('Connection config TOML: table is nil.');

  if not ATable.TryGetValue('engine', V) or (V = nil) then
    raise EArgumentException.Create('Connection config TOML: key "engine" is required.');
  EngineStr := TomlValueToText(V, 'engine');
  if not StringToEngine(EngineStr, Engine) then
    raise EArgumentException.CreateFmt('Unknown engine: %s', [EngineStr]);

  Result := TConnection.Create(Engine);

  if ATable.TryGetValue('driver', V) and (V <> nil) then
  begin
    if StringToDriver(TomlValueToText(V, 'driver'), Driver) then
      Result.Driver := Driver;
  end;

  if ATable.TryGetValue('host', V) and (V <> nil) then
    Result.Host := TomlValueToText(V, 'host');
  if ATable.TryGetValue('port', V) and (V <> nil) then
  begin
    PortVal := TomlReadPort(V, 'port');
    if PortVal > 0 then
      Result.Port := PortVal;
  end;
  if ATable.TryGetValue('schema', V) and (V <> nil) then
    Result.Schema := TomlValueToText(V, 'schema');
  if ATable.TryGetValue('database', V) and (V <> nil) then
    Result.Database := TomlValueToText(V, 'database');
  if ATable.TryGetValue('username', V) and (V <> nil) then
    Result.Username := TomlValueToText(V, 'username');
  if ATable.TryGetValue('password', V) and (V <> nil) then
    Result.Password := TomlValueToText(V, 'password');

  if ATable.TryGetValue('args', V) and (V <> nil) then
  begin
    if not (V.ValueType in [tvtTable, tvtInlineTable]) then
      raise EArgumentException.Create('Connection config TOML: "args" must be a table.');
    ArgsTbl := V.AsTable;
    for I := 0 to ArgsTbl.Items.Count - 1 do
    begin
      ArgKey := ArgsTbl.Items.GetKey(I);
      Result.AddArgument(ArgKey, TomlValueToText(ArgsTbl.Items.GetValue(I), 'args.' + ArgKey));
    end;
  end;
end;

end.
