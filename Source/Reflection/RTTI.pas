{
  RTTI.
  ------------------------------------------------------------------------------
  Objetivo : Simplificar a convesão, formatação e comparação de valores
  monetários e quantitativos em Delphi.
  Suporta 2 Modos de Resultado: ResultMode = (Truncate, Round);
  Suporta 2 Formatos de Resultado: ResultFormat = (BR, DB);
  OBS.:
  1 - O Formato DB é o Mesmo Utilizado em Campos Decimais, Double ou Float,
  de Bancos de Dados como MySQL/MariaDB, PostgreSQL, SQLite e etc...
  2 - Como Recomendação ao Definir seus Campos Monetários no Banco de Dados,
  Utilize um comprimento de grandeza igual ou superior à 18, ex: Decimal(18,x).
  3 - Não Serão Adicionados Símbolos Monetários como: R$, US$, etc...
  ------------------------------------------------------------------------------
  Autor : Nickson Jeanmerson
  Co-Autor : Wellington Fonseca
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

unit RTTI;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.DateUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.NetEncoding,
  System.Threading,
  System.JSON,
  System.Math,
  System.RTTI,
  System.TypInfo,
  System.Generics.Collections
  ;

type
  TEnumConverter = class
  public
    { Public declarations }
    class function EnumToInt<T>(const EnumValue: T): Integer;
    class function EnumToString<T>(EnumValue: T): string;
  end;

type
  TEnumeration<T: record> = class
  strict private
    class function TypeInfo: PTypeInfo; inline; static;
    class function TypeData: PTypeData; inline; static;
  public
    class function IsEnumeration: Boolean; static;
    class function ToOrdinal(Enum: T): Integer; inline; static;
    class function FromOrdinal(Value: Integer): T; inline; static;
    class function MinValue: Integer; inline; static;
    class function MaxValue: Integer; inline; static;
    class function InRange(Value: Integer): Boolean; inline; static;
    class function EnsureRange(Value: Integer): Integer; inline; static;
  end;

type
  TRTTI = class
    public
    { Public declarations }
    class function DynArrayVariantToValue(const Value: Variant): TValue; overload;
    class function DynArrayVariantToValue(const Value: Variant; TypeInfo: Pointer): TValue; overload;
    class function RunMethod(ClassName: String; MethodName : String; MethodParams : TArray<TValue>) : TValue; overload;
    class function RunMethod(ClassName: TArray<String>; MethodName : TArray<String>; MethodParams : TArray<TValue>) : TObjectList<TObject>; overload;
  end;

type
  TypeResolver = class
    public
    { Public declarations }
    class function ReCast<T>(const AValue): T;
    class function Format<T>(const AValue : T): String;
    class function GetOrdValue(Info: PTypeInfo; const T): Integer;
    class procedure SetOrdValue(Info: PTypeInfo; var T; Value: Integer);
  end;

implementation

{ TGenericType }

class function TypeResolver.ReCast<T>(const AValue): T;
begin
  Result := T(AValue);
end;

class function TypeResolver.Format<T>(const AValue: T): string;
begin
  Result := String(TValue.From(AValue).TypeInfo.Name);
end;

class function TypeResolver.GetOrdValue(Info: PTypeInfo; const T): Integer;
begin
  Result := 0;
  case GetTypeData(Info)^.OrdType of
    otSByte, otUByte:
      Result := Byte(T);
    otSWord, otUWord:
      Result := Word(T);
    otSLong, otULong:
      Result := Integer(T);
  end;
end;

class procedure TypeResolver.SetOrdValue(Info: PTypeInfo; var T; Value: Integer);
begin
  case GetTypeData(Info)^.OrdType of
    otSByte, otUByte:
      Byte(T) := Value;
    otSWord, otUWord:
      Word(T) := Value;
    otSLong, otULong:
      Integer(T) := Value;
  end;
end;

{ TEnumConverter }

class function TEnumConverter.EnumToInt<T>(const EnumValue: T): Integer;
begin
  Result := 0;
  Move(EnumValue, Result, sizeOf(EnumValue));
end;

class function TEnumConverter.EnumToString<T>(EnumValue: T): String;
begin
  Result := GetEnumName(TypeInfo(T), EnumToInt(EnumValue));
end;

{ TEnumeration<T> }

class function TEnumeration<T>.TypeInfo: PTypeInfo;
begin
  Result := System.TypeInfo(T);
end;

class function TEnumeration<T>.TypeData: PTypeData;
begin
  Result := System.TypInfo.GetTypeData(TypeInfo);
end;

class function TEnumeration<T>.IsEnumeration: Boolean;
begin
  Result := TypeInfo.Kind=tkEnumeration;
end;

class function TEnumeration<T>.ToOrdinal(Enum: T): Integer;
begin
  Assert(IsEnumeration);
  Assert(SizeOf(Enum)<=SizeOf(Result));
  Result := 0;
  Move(Enum, Result, SizeOf(Enum));
  Assert(InRange(Result));
end;

class function TEnumeration<T>.FromOrdinal(Value: Integer): T;
begin
  Assert(IsEnumeration);
  Assert(InRange(Value));
  Assert(SizeOf(Result)<=SizeOf(Value));
  Move(Value, Result, SizeOf(Result));
end;

class function TEnumeration<T>.MinValue: Integer;
begin
  Assert(IsEnumeration);
  Result := TypeData.MinValue;
end;

class function TEnumeration<T>.MaxValue: Integer;
begin
  Assert(IsEnumeration);
  Result := TypeData.MaxValue;
end;

class function TEnumeration<T>.InRange(Value: Integer): Boolean;
var
  ptd: PTypeData;
begin
  Assert(IsEnumeration);
  ptd := TypeData;
  Result := System.Math.InRange(Value, ptd.MinValue, ptd.MaxValue);
end;

class function TEnumeration<T>.EnsureRange(Value: Integer): Integer;
var
  ptd: PTypeData;
begin
  Assert(IsEnumeration);
  ptd := TypeData;
  Result := System.Math.EnsureRange(Value, ptd.MinValue, ptd.MaxValue);
end;

{ TRTTI }

class function TRTTI.RunMethod(ClassName : TArray<String>; MethodName : TArray<String>; MethodParams : TArray<TValue>): TObjectList<TObject>;
var
  I : Integer;
begin
  Result := nil;
  for I := 0 to Length(ClassName) - 1 do
    Result := Self.RunMethod(ClassName[I], MethodName[I], MethodParams).AsType<TObjectList<TObject>>;
end;

class function TRTTI.RunMethod(ClassName : String; MethodName : String; MethodParams : TArray<TValue>): TValue;
var
  Context: TRttiContext;
  Instance: TRttiInstanceType;
  Method: TRttiMethod;
begin
  Context := TRttiContext.Create;
  Instance := Context.FindType(ClassName).AsInstance;
  Method := nil;
  Result := nil;
  try
    if Assigned(Instance) then
      begin
        Method := Instance.GetMethod(MethodName);
        if Assigned(Method) then
          Result := Method.Invoke(Instance.MetaclassType, MethodParams);
      end;
  finally
    Method.Free;
    Context.Free;
  end;
end;

class function TRTTI.DynArrayVariantToValue(const Value: Variant; TypeInfo: Pointer): TValue;
var
  PointerHandle: Pointer;
begin
  PointerHandle := nil;
  DynArrayFromVariant(PointerHandle, Value, TypeInfo);
  TValue.MakeWithoutCopy(@PointerHandle, TypeInfo, Result);
end;

class function TRTTI.DynArrayVariantToValue(const Value: Variant): TValue;
begin
  case VarType(Value) and not varArray of
    varSmallint: Result := TValue.From(Value);
    varInteger: Result := TValue.From(Value);
    varSingle: Result := TValue.From(Value);
    varDouble: Result := TValue.From(Value);
    varCurrency: Result := TValue.From(Value);
    varDate: Result := TValue.From(Value);
    varOleStr: Result := TValue.From(Value);
    varDispatch: Result := TValue.From(Value);
    varError: Result := TValue.From(Value);
    varBoolean: Result := TValue.From(Value);
    varVariant: Result := TValue.From(Value);
    varUnknown: Result := TValue.From(Value);
    varShortInt: Result := TValue.From(Value);
    varByte: Result := TValue.From(Value);
    varWord: Result := TValue.From(Value);
    varLongWord: Result := TValue.From(Value);
    varInt64: Result := TValue.From(Value);
    varUInt64: Result := TValue.From(Value);
    varUString: Result := TValue.From(Value);
  end;
end;

end.
