                                                     {
  Type.Array.Intf — matrizes associativas (contrato genérico).
  ------------------------------------------------------------------------------
  Objetivo : Simplificar a criaусo de matrizes php-like em Delphi.
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
  Esta biblioteca ж software livre; vocЖ pode redistribuь-la e/ou modificр-la
  sob os termos da Licenуa PЩblica Geral Menor do GNU conforme publicada pela
  Free Software Foundation; tanto a versсo 3.29 da Licenуa, ou (a seu critжrio)
  qualquer versсo posterior.
  Esta biblioteca ж distribuьda na expectativa de que seja Щtil, porжm, SEM
  NENHUMA GARANTIA; nem mesmo a garantia implьcita de COMERCIABILIDADE OU
  ADEQUAК├O A UMA FINALIDADE ESPEC═FICA. Consulte a Licenуa PЩblica Geral Menor
  do GNU para mais detalhes. (Arquivo LICENКA.TXT ou LICENSE.TXT)
  VocЖ deve ter recebido uma cзpia da Licenуa PЩblica Geral Menor do GNU junto
  com esta biblioteca; se nсo, escreva para a Free Software Foundation, Inc.,
  no endereуo 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.
  VocЖ tambжm pode obter uma copia da licenуa em:
  http://www.opensource.org/licenses/lgpl-license.php
}

unit &Type.&Array.Intf;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Defaults,
  System.Generics.Collections;

type
  IArrayInterface<T> = interface
    ['{830624AE-D851-40F1-ABD5-F1E5BE858446}']
    function GetKey(Index: Integer): String;
    function GetValues(Index: String): string;
    function GetValuesAtIndex(Index: Integer): string;
    procedure SetValues(Index: String; Const Value: String);
    function GetItem(Index: String): String;
    procedure SetItem(Index: String; Const Value: String);
    procedure DoCopy(Collection: T);
    procedure Assign(Collection: T);
    function ToKeys(Prettify: Boolean = False): string;
    function ToValues(Prettify: Boolean = False): string;
    function ToList(Prettify: Boolean = False): string;
    function ToTags(Prettify: Boolean = False): string;
    function ToXML(Prettify: Boolean = False): string;
    function ToJSON(Prettify: Boolean = False): string;
    procedure Add(Key, Value: string); overload;
    procedure AddKeyValue(Key, Value: string);
  end;

implementation

end.
