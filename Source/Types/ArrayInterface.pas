                                                     {
  ArrayInterface.
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

unit ArrayInterface;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Defaults,
  System.Generics.Collections
  ;

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
    function ToKeys(Prettify : Boolean = False): string;
    function ToValues(Prettify : Boolean = False): string;
    function ToList(Prettify : Boolean = False): string;
    function ToTags(Prettify : Boolean = False): string;
    function ToXML(Prettify : Boolean = False): string;
    function ToJSON(Prettify : Boolean = False): string;
    procedure Add(Key, Value: string); overload;
    procedure AddKeyValue(Key, Value: string);
  end;

implementation

end.