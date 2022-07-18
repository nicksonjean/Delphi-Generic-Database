{
  &Array.
  ------------------------------------------------------------------------------
  Objetivo : Simplificar a criação de matrizes php-like em Delphi.
  Suporta 1 Tipo de Matriz Associativa Unidimensional Baseada em TStringList;
  Suporta 2 Tipos de Matrizes Associativas Unidimensionais Baseadas em TDicionary;
  Suporte 2 Tipos de Matrizes Associativas Multidimensional Baseadas em TDicionary;
  1 - Matriz de Strings Herdada de TStringList;
  2 - Matriz de Variants Herdada de TDictionary<Variant, Variant>
  3 - Matriz de Fields Herdade de TDictionay<Variant, TField>
  4 - Matriz de Matrizes Herdada de TDicionary<TDictionay<Variant, Variant>>
  5 - Matriz de Matrizes Herdada de TDicionary<TDictionay<Variant, TField>>
  ------------------------------------------------------------------------------
  Autor : Nickson Jeanmerson
  Colaborador : Ramon Ruan
  ------------------------------------------------------------------------------
  Esta biblioteca é software livre; você pode redistribuí-la e/ou modificá-la
  sob os termos da Licença Pública Geral Menor do GNU conforme publicada pela
  Free Software Foundation; tanto a versão 3.29 da Licença, ou (a seu critério)
  qualquer versão posterior.
  Esta biblioteca é distribuída na expectativa de que seja útil, porém, SEM
  NENHUMA GARANTIA; nem mesmo a garantia implícita de COMERCIABILIDADE OU
  ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA. Consulte a Licença Pública Geral Menor
  do GNU para mais detalhes. (Arquivo LICENÇA.TXT ou LICENSE.TXT)
  Você deve ter recebido uma cópia da Licença Pública Geral Menor do GNU junto
  com esta biblioteca; se não, escreva para a Free Software Foundation, Inc.,
  no endereço 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.
  Você também pode obter uma copia da licença em:
  http://www.opensource.org/licenses/lgpl-license.php
}

unit &Array;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Defaults,
  System.RTTI,
  System.TypInfo,
  System.Generics.Collections,
  Data.DB,
  RTTI,

  FMX.Dialogs
  ;

type
  TArray<T : class, constructor> = class
  private
    { Private declarations }
    FGeneric : T;
    function GetKey(Index: Integer): String;
    function GetValues(Name: String): TValue;
    function GetValuesAtIndex(Index: Integer): TValue;
    procedure SetValues(Name: String; Const Value: TValue);
    function GetItem(Index: String): TValue;
    procedure SetItem(Index: String; Const Value: TValue);
    procedure DoCopy(Collection: T);
  public
    { Public declarations }
    function Access : T;
    constructor Create; overload;
    destructor Destroy; override;
    procedure Assign(Collection: T);
    function ToKeys(Prettify : Boolean = False): String;
    function ToValues(Prettify : Boolean = False): String;
    function ToList(Prettify : Boolean = False): String;
    function ToTags(Prettify : Boolean = False): String;
    function ToXML(Prettify : Boolean = False): String;
    function ToJSON(Prettify : Boolean = False): String;
    procedure Add(Key: String; Value: TValue);
    procedure AddKeyValue(Key: String; Value: TValue);
    property Key[Index: Integer]: String read GetKey;
    property ValuesAtIndex[Index: Integer]: TValue read GetValuesAtIndex;
    property Values[Name: String]: TValue read GetValues write SetValues;
    property Item[Index: String]: TValue read GetItem write SetItem; default;
  end;

implementation

uses
  ArrayString,
  ArrayVariant,
  ArrayField;

{ TArray<T> }

constructor TArray<T>.Create;
begin
  FGeneric := T.Create;
end;

destructor TArray<T>.Destroy;
begin
  inherited Destroy;
end;

procedure TArray<T>.Add(Key: String; Value: TValue);
begin
  if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayString') then
  begin
    if TArrayString(FGeneric) <> nil then
      TArrayString(FGeneric).Add(Key, Value.AsString);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayVariant') then
  begin
    if TArrayVariant(FGeneric) <> nil then
      TArrayVariant(FGeneric).Add(Key, Value.AsVariant);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayField') then
  begin
    if TArrayField(FGeneric) <> nil then
      TArrayField(FGeneric).Add(Key, TypeResolver.ReCast<TField>(Value));
  end;
end;

procedure TArray<T>.AddKeyValue(Key: String; Value: TValue);
begin
  if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayString') then
  begin
    if TArrayString(FGeneric) <> nil then
      TArrayString(FGeneric).AddKeyValue(Key, Value.AsVariant);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayVariant') then
  begin
    if TArrayVariant(FGeneric) <> nil then
      TArrayVariant(FGeneric).AddKeyValue(Key, Value.AsVariant);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayField') then
  begin
    if TArrayField(FGeneric) <> nil then
      TArrayField(FGeneric).AddKeyValue(Key, TypeResolver.ReCast<TField>(Value));
  end;
end;

procedure TArray<T>.Assign(Collection: T);
begin
  if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayString') then
  begin
    if TArrayString(FGeneric) <> nil then
      TArrayString(FGeneric).Assign(TArrayString(Collection));
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayVariant') then
  begin
    if TArrayVariant(FGeneric) <> nil then
      TArrayVariant(FGeneric).Assign(TArrayVariant(Collection));
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayField') then
  begin
    if TArrayField(FGeneric) <> nil then
      TArrayField(FGeneric).Assign(TArrayField(Collection));
  end;
end;

procedure TArray<T>.DoCopy(Collection: T);
var
  I: Integer;
begin
  if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayString') then
  begin
    if TArrayString(FGeneric) <> nil then
    begin
      for I := 0 to TArrayString(Collection).Count - 1 do
        TArrayString(FGeneric).Add(TArrayString(Collection).Names[I], TArrayString(Collection).ValuesAtIndex[I]);
    end;
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayVariant') then
  begin
    if TArrayVariant(FGeneric) <> nil then
    begin
      for I := 0 to TArrayVariant(Collection).Count - 1 do
        TArrayVariant(FGeneric).Add(TArrayVariant(Collection).Key[I], TArrayVariant(Collection).ValuesAtIndex[I]);
    end;
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayField') then
  begin
    if TArrayField(FGeneric) <> nil then
    begin
      for I := 0 to TArrayField(Collection).Count - 1 do
        TArrayField(FGeneric).Add(TArrayField(Collection).Key[I], TArrayField(Collection).ValuesAtIndex[I]);
    end;
  end;

end;

function TArray<T>.GetItem(Index: String): TValue;
begin
  if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayString') then
  begin
    if TArrayString(FGeneric) <> nil then
      TArrayString(FGeneric).GetItem(Index);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayVariant') then
  begin
    if TArrayVariant(FGeneric) <> nil then
      TArrayVariant(FGeneric).GetItem(Index);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayField') then
  begin
    if TArrayField(FGeneric) <> nil then
      TArrayField(FGeneric).GetItem(Index);
  end;
end;

function TArray<T>.GetKey(Index: Integer): String;
begin
  if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayString') then
  begin
    if TArrayString(FGeneric) <> nil then
      TArrayString(FGeneric).GetKey(Index);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayVariant') then
  begin
    if TArrayVariant(FGeneric) <> nil then
      TArrayVariant(FGeneric).GetKey(Index);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayField') then
  begin
    if TArrayField(FGeneric) <> nil then
      TArrayField(FGeneric).GetKey(Index);
  end;
end;

function TArray<T>.GetValues(Name: String): TValue;
begin
  if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayString') then
  begin
    if TArrayString(FGeneric) <> nil then
      TArrayString(FGeneric).GetValues(Name);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayVariant') then
  begin
    if TArrayVariant(FGeneric) <> nil then
      TArrayVariant(FGeneric).GetValues(Name);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayField') then
  begin
    if TArrayField(FGeneric) <> nil then
      TArrayField(FGeneric).GetValues(Name);
  end;
end;

function TArray<T>.GetValuesAtIndex(Index: Integer): TValue;
begin
  if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayString') then
  begin
    if TArrayString(FGeneric) <> nil then
      TArrayString(FGeneric).GetValuesAtIndex(Index);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayVariant') then
  begin
    if TArrayVariant(FGeneric) <> nil then
      TArrayVariant(FGeneric).GetValuesAtIndex(Index);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayField') then
  begin
    if TArrayField(FGeneric) <> nil then
      TArrayField(FGeneric).GetValuesAtIndex(Index);
  end;
end;

procedure TArray<T>.SetItem(Index: String; const Value: TValue);
begin
  if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayString') then
  begin
    if TArrayString(FGeneric) <> nil then
      TArrayString(FGeneric).SetItem(Index, Value.AsString);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayVariant') then
  begin
    if TArrayVariant(FGeneric) <> nil then
      TArrayVariant(FGeneric).SetItem(Index, Value.AsVariant);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayField') then
  begin
    if TArrayField(FGeneric) <> nil then
      TArrayField(FGeneric).SetItem(Index, TypeResolver.ReCast<TField>(Value));
  end;
end;

procedure TArray<T>.SetValues(Name: String; const Value: TValue);
begin
  if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayString') then
  begin
    if TArrayString(FGeneric) <> nil then
      TArrayString(FGeneric).SetValues(Name, Value.AsString);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayVariant') then
  begin
    if TArrayVariant(FGeneric) <> nil then
      TArrayVariant(FGeneric).SetValues(Name, Value.AsVariant);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayField') then
  begin
    if TArrayField(FGeneric) <> nil then
      TArrayField(FGeneric).SetValues(Name, TypeResolver.ReCast<TField>(Value));
  end;
end;

function TArray<T>.ToJSON(Prettify: Boolean): String;
begin
  if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayString') then
  begin
    if TArrayString(FGeneric) <> nil then
      TArrayString(FGeneric).ToJSON(Prettify);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayVariant') then
  begin
    if TArrayVariant(FGeneric) <> nil then
      TArrayVariant(FGeneric).ToJSON(Prettify);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayField') then
  begin
    if TArrayField(FGeneric) <> nil then
      TArrayField(FGeneric).ToJSON(Prettify);
  end;
end;

function TArray<T>.ToKeys(Prettify: Boolean): String;
begin
  if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayString') then
  begin
    if TArrayString(FGeneric) <> nil then
      TArrayString(FGeneric).ToKeys(Prettify);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayVariant') then
  begin
    if TArrayVariant(FGeneric) <> nil then
      TArrayVariant(FGeneric).ToKeys(Prettify);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayField') then
  begin
    if TArrayField(FGeneric) <> nil then
      TArrayField(FGeneric).ToKeys(Prettify);
  end;
end;

function TArray<T>.ToList(Prettify: Boolean): String;
begin
  if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayString') then
  begin
    if TArrayString(FGeneric) <> nil then
      TArrayString(FGeneric).ToList(Prettify);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayVariant') then
  begin
    if TArrayVariant(FGeneric) <> nil then
      TArrayVariant(FGeneric).ToList(Prettify);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayField') then
  begin
    if TArrayField(FGeneric) <> nil then
      TArrayField(FGeneric).ToList(Prettify);
  end;
end;

function TArray<T>.ToTags(Prettify: Boolean): String;
begin
  if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayString') then
  begin
    if TArrayString(FGeneric) <> nil then
      TArrayString(FGeneric).ToTags(Prettify);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayVariant') then
  begin
    if TArrayVariant(FGeneric) <> nil then
      TArrayVariant(FGeneric).ToTags(Prettify);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayField') then
  begin
    if TArrayField(FGeneric) <> nil then
      TArrayField(FGeneric).ToTags(Prettify);
  end;
end;

function TArray<T>.ToValues(Prettify: Boolean): String;
begin
  if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayString') then
  begin
    if TArrayString(FGeneric) <> nil then
      TArrayString(FGeneric).ToValues(Prettify);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayVariant') then
  begin
    if TArrayVariant(FGeneric) <> nil then
      TArrayVariant(FGeneric).ToValues(Prettify);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayField') then
  begin
    if TArrayField(FGeneric) <> nil then
      TArrayField(FGeneric).ToValues(Prettify);
  end;
end;

function TArray<T>.ToXML(Prettify: Boolean): String;
begin
  if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayString') then
  begin
    if TArrayString(FGeneric) <> nil then
      TArrayString(FGeneric).ToXML(Prettify);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayVariant') then
  begin
    if TArrayVariant(FGeneric) <> nil then
      TArrayVariant(FGeneric).ToXML(Prettify);
  end
  else if (PTypeInfo(TypeInfo(T))^.Name = 'TArrayField') then
  begin
    if TArrayField(FGeneric) <> nil then
      TArrayField(FGeneric).ToXML(Prettify);
  end;
end;

function TArray<T>.Access: T;
begin
  Result := FGeneric;
end;

end.