{
  ReflectionClass.RTTI.
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


  https://delphi-developers-archive.blogspot.com/2015/04/hi_16.html
  https://stackoverflow.com/questions/48690532/returning-an-objectlist-from-rtti-in-delphi
  https://stackoverflow.com/questions/28922070/how-can-i-get-the-sub-item-type-of-a-tobjectlistt-purely-by-rtti-information
  http://edgarpavao.com/2017/07/01/um-pouco-sobre-o-tvalue/
  http://tireideletra.wbagestao.com/index.php/page/7/
  https://stackoverflow.com/questions/2559049/delphi-rtti-and-tobjectlisttobject
  https://stackoverflow.com/questions/48828365/rtti-invoke-a-class-method-says-invalid-type-cast
  https://android.developreference.com/article/12584253/Returning+an+ObjectList+from+RTTI+in+delphi
  https://stackoverflow.com/questions/46433385/einvalidcast-wih-mock-function-returning-a-pointer-type
  https://code5.cn/so/delphi/701002
  https://stackoverflow.com/questions/23863815/how-to-get-tvirtualinterfaces-invoke-method-argument-names
  https://stackoverflow.com/questions/48334544/how-to-pass-an-array-of-pointer-types-to-rttimethods-invoke-in-delphi
  https://stackoverflow.com/questions/32393566/how-do-i-use-a-string-in-trttimethod-invoke-as-parameter-properly
  https://stackoverflow.com/questions/18289782/delphi-rtti-using-method-invoke-for-tkenumeration-parameter
  https://stackoverflow.com/questions/42412051/convert-targlist-argument-to-tvalue
  https://stackoverflow.com/questions/2559049/delphi-rtti-and-tobjectlisttobject
  https://stackoverflow.com/questions/28922070/how-can-i-get-the-sub-item-type-of-a-tobjectlistt-purely-by-rtti-information
  https://stackoverflow.com/questions/10192534/delphi-invoke-record-method-per-name/10194803

  http://www.andrecelestino.com/delphi-validando-propriedades-de-uma-classe-com-rtti/
  https://www.andrecelestino.com/delphi-usando-uma-classe-sem-usa-la/
  https://www.webtips.com.br/Home/Detail/6
  http://www.luizsistemas.com.br/2012/10/reflection-que-tal-um-orm-basico-parte-2/
  https://showdelphi.com.br/executar-metodos-de-classe-pelo-nome-e-sem-precisar-dar-uses-da-unit/
  https://delphisorcery.blogspot.com/2012/06/bug-or-no-bug-that-is-question.html
  https://stackoverflow.com/questions/48828365/rtti-invoke-a-class-method-says-invalid-type-cast
  https://github.com/amarildolacerda/helpers/blob/master/System.Classes.Helper.pas
}

unit ReflectionClass.RTTI;

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
  System.Rtti,
  System.Generics.Collections
  ;

type
  TClassRTTI = class
    private
    { Private declarations }
    public
    { Public declarations }
    class function DynArrayVariantToValue(const Value: Variant): TValue; overload;
    class function DynArrayVariantToValue(const Value: Variant; TypeInfo: Pointer): TValue; overload;
    class function RunMethod(ClassName: String; MethodName : String; MethodParams : TArray<TValue>) : TValue; overload;
    class function RunMethod(ClassName: TArray<String>; MethodName : TArray<String>; MethodParams : TArray<TValue>) : TObjectList<TObject>; overload;
  end;

{ TClassRTTI }

class function TClassRTTI.RunMethod(ClassName : TArray<String>; MethodName : TArray<String>; MethodParams : TArray<TValue>): TObjectList<TObject>;
var
  I : Integer;
begin
  Result := nil;
  for I := 0 to Length(ClassName) - 1 do
    Result := Self.RunMethod(ClassName[I], MethodName[I], MethodParams).AsType<TObjectList<TObject>>;
end;

class function TClassRTTI.RunMethod(ClassName : String; MethodName : String; MethodParams : TArray<TValue>): TValue;
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

class function TClassRTTI.DynArrayVariantToValue(const Value: Variant; TypeInfo: Pointer): TValue;
var
  PointerHandle: Pointer;
begin
  PointerHandle := nil;
  DynArrayFromVariant(PointerHandle, Value, TypeInfo);
  TValue.MakeWithoutCopy(@PointerHandle, TypeInfo, Result);
end;

class function TClassRTTI.DynArrayVariantToValue(const Value: Variant): TValue;
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
