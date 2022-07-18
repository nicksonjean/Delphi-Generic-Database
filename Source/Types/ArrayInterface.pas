                                                     {
  ArrayInterface.
  ------------------------------------------------------------------------------
  Objetivo : Simplificar a cria��o de matrizes php-like em Delphi.
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
  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la
  sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela
  Free Software Foundation; tanto a vers�o 3.29 da Licen�a, ou (a seu crit�rio)
  qualquer vers�o posterior.
  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM
  NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU
  ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor
  do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)
  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto
  com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,
  no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.
  Voc� tamb�m pode obter uma copia da licen�a em:
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