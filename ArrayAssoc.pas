unit ArrayAssoc;

{$WARNINGS OFF}
{$HINTS OFF}

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  System.RTLConsts;

type
  TArray = class(TStringList)
  private
    function GetValues(Index: string): string;
    function GetValuesAtIndex(Index: Integer): string;
    procedure SetValues(Index: string; const Value: string);
  public
    constructor Create;
    destructor Destroy; override;
    function ToFilter: string;
    function ToString: string;
    procedure AddKeyValue(Key, Value: string);
    property ValuesAtIndex[Index: Integer]: string read GetValuesAtIndex;
    property Values[Index: string]: string read GetValues
      write SetValues; default;
  end;

  { TRows em Desuso }

type
  TRows = class(TList)
  private
    function GetData(Index: Integer): TArray;
    procedure SetData(Index: Integer; const Value: TArray);
  public
    property Data[Index: Integer]: TArray read GetData write SetData; default;
    destructor Destroy; override;
  end;

implementation

{ TArray }

procedure TArray.AddKeyValue(Key, Value: string);
begin
  Add(Key + NameValueSeparator + Value);
end;

constructor TArray.Create;
begin
  NameValueSeparator := '|';
end;

destructor TArray.Destroy;
begin
  inherited;
end;

function TArray.ToFilter: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Count - 1 do
  begin
    Result := Result + Names[I] + ' ' + ValuesAtIndex[I] + ' ';
  end;
end;

function TArray.ToString: string;
var
  I: Integer;
  Return: String;
begin
  Return := '';
  for I := 0 to Count - 1 do
  begin
    Return := Return + ValuesAtIndex[I];
  end;
  Return := Copy(Return, 1, Length(Return) - 1);
  Result := Return;
end;

function TArray.GetValues(Index: string): string;
begin
  Result := inherited Values[Index];
end;

function TArray.GetValuesAtIndex(Index: Integer): string;
begin
  Result := inherited Values[Names[Index]];
end;

procedure TArray.SetValues(Index: string; const Value: string);
begin
  inherited Values[Index] := Value;
end;

{ TRows }

destructor TRows.Destroy;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Data[I].Free;
  inherited;
end;

function TRows.GetData(Index: Integer): TArray;
begin
  Result := Items[Index];
end;

procedure TRows.SetData(Index: Integer; const Value: TArray);
begin
  Items[Index] := Value;
end;

{$WARNINGS ON}
{$HINTS ON}

end.
