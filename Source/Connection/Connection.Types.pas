unit Connection.Types;

{
  Connection.Types
  ------------------------------------------------------------------------------
  Objetivo: Compartilhar tipos base por todas as camadas do projeto:
    TDriver    — identificador do banco de dados (independente de engine)
    TEngine    — identificador da biblioteca de acesso (FireDAC, dbExpress, ZeOS, UniDAC)
    TConnectionParams — record com todos os parâmetros de uma conexão
  ------------------------------------------------------------------------------
  Não importa nenhuma unit de engine específica.
}

interface

uses
  System.SysUtils,
  System.Generics.Collections;

type
  { Tipo de banco de dados — independente de engine }
  TDriver = (SQLite, MySQL, Firebird, Interbase, MSSQL, PostgreSQL, Oracle);

  { Engine de acesso a dados }
  TEngine = (FireDAC, dbExpress, ZeOS, UniDAC);

  { Ambiente de execução }
  TEnvironment = (Local, Developer, Stage, Production);

  { Parâmetros de conexão.
    ExtraArgs NÃO é owned por este record — o dono é o TConnection que o criou.
    A cópia do record faz shallow copy do ponteiro ExtraArgs. }
  TConnectionParams = record
  public
    Driver:    TDriver;
    Host:      String;
    Port:      Integer;
    Schema:    String;
    Database:  String;
    Username:  String;
    Password:  String;
    { Parâmetros adicionais livres: CharacterSet, lc_ctype, Compress, Pooled, etc.
      Chave case-insensitive não garantida — use sempre a mesma capitalização. }
    ExtraArgs: TDictionary<String, String>;
    { Retorna uma instância padrão sem ExtraArgs alocado }
    class function Default: TConnectionParams; static;
  end;

{ Nomes dos valores de TEngine como String — para serialização/log }
function EngineToString(const AEngine: TEngine): String;
function StringToEngine(const AName: String; out AEngine: TEngine): Boolean;
function DriverToString(const ADriver: TDriver): String;
function StringToDriver(const AName: String; out ADriver: TDriver): Boolean;

{ Portas padrão por driver }
function DefaultPort(const ADriver: TDriver): Integer;

implementation

class function TConnectionParams.Default: TConnectionParams;
begin
  Result.Driver    := TDriver.SQLite;
  Result.Host      := EmptyStr;
  Result.Port      := 0;
  Result.Schema    := EmptyStr;
  Result.Database  := EmptyStr;
  Result.Username  := EmptyStr;
  Result.Password  := EmptyStr;
  Result.ExtraArgs := nil;
end;

function EngineToString(const AEngine: TEngine): String;
begin
  case AEngine of
    TEngine.FireDAC:   Result := 'FireDAC';
    TEngine.dbExpress: Result := 'dbExpress';
    TEngine.ZeOS:      Result := 'ZeOS';
    TEngine.UniDAC:    Result := 'UniDAC';
  else
    Result := 'Unknown';
  end;
end;

function StringToEngine(const AName: String; out AEngine: TEngine): Boolean;
var
  Upper: String;
begin
  Upper := UpperCase(AName);
  if Upper = 'FIREDAC' then begin AEngine := TEngine.FireDAC;   Result := True; end
  else if Upper = 'DBEXPRESS' then begin AEngine := TEngine.dbExpress; Result := True; end
  else if Upper = 'ZEOS' then begin AEngine := TEngine.ZeOS;      Result := True; end
  else if Upper = 'UNIDAC' then begin AEngine := TEngine.UniDAC;    Result := True; end
  else Result := False;
end;

function DriverToString(const ADriver: TDriver): String;
begin
  case ADriver of
    TDriver.SQLite:     Result := 'SQLite';
    TDriver.MySQL:      Result := 'MySQL';
    TDriver.Firebird:   Result := 'Firebird';
    TDriver.Interbase:  Result := 'Interbase';
    TDriver.MSSQL:      Result := 'MSSQL';
    TDriver.PostgreSQL: Result := 'PostgreSQL';
    TDriver.Oracle:     Result := 'Oracle';
  else
    Result := 'Unknown';
  end;
end;

function StringToDriver(const AName: String; out ADriver: TDriver): Boolean;
var
  Upper: String;
begin
  Upper := UpperCase(AName);
  if Upper = 'SQLITE' then begin ADriver := TDriver.SQLite;     Result := True; end
  else if (Upper = 'MYSQL') or (Upper = 'MARIADB') then begin ADriver := TDriver.MySQL;  Result := True; end
  else if Upper = 'FIREBIRD' then begin ADriver := TDriver.Firebird;   Result := True; end
  else if Upper = 'INTERBASE' then begin ADriver := TDriver.Interbase;  Result := True; end
  else if (Upper = 'MSSQL') or (Upper = 'SQLSERVER') then begin ADriver := TDriver.MSSQL;  Result := True; end
  else if Upper = 'POSTGRESQL' then begin ADriver := TDriver.PostgreSQL; Result := True; end
  else if Upper = 'ORACLE' then begin ADriver := TDriver.Oracle;     Result := True; end
  else Result := False;
end;

function DefaultPort(const ADriver: TDriver): Integer;
begin
  case ADriver of
    TDriver.SQLite:     Result := 0;
    TDriver.MySQL:      Result := 3306;
    TDriver.Firebird:   Result := 3050;
    TDriver.Interbase:  Result := 3050;
    TDriver.MSSQL:      Result := 1433;
    TDriver.PostgreSQL: Result := 5432;
    TDriver.Oracle:     Result := 1521;
  else
    Result := 0;
  end;
end;

end.
