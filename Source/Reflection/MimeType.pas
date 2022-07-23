{
  MimeType.
  ------------------------------------------------------------------------------
  Objetivo : Detectar a MimeType de um Arquivo ou Stream Atrav�s N�meros M�gicos.
  ------------------------------------------------------------------------------
  Autor : Nickson Jeanmerson
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

unit MimeType;

interface

uses
  System.SysUtils,
  System.IOUtils,
  System.StrUtils,
  System.DateUtils,
  System.Classes,
  System.Math,
  System.SyncObjs,
  System.Threading,
  System.Generics.Collections,
  System.RTLConsts,
  System.Variants,
  System.JSON,
  System.RTTI,
  System.TypInfo,
  System.NetEncoding,
  Strings
  ;

type
  TCardinalArray = Array[0..MaxInt div SizeOf(Cardinal)-1] of Cardinal;
  PCardinalArray = ^TCardinalArray;
  TBinaryMode = (Read, Write);

const
  JPEG_CONTENT_TYPE = 'image/jpeg';
  HTML_CONTENT_TYPE = 'text/html; charset=UTF-8';
  XML_CONTENT_TYPE = 'text/xml; charset=UTF-8';
  TEXT_CONTENT_TYPE = 'text/plain; charset=UTF-8';
  JSON_CONTENT_TYPE = 'application/json; charset=UTF-8';
  JSON_CONTENT_TYPE_VAR = JSON_CONTENT_TYPE;
  BINARY_CONTENT_TYPE = 'application/octet-stream';
  HEADER_CONTENT_TYPE = 'Content-Type: ';

type
  TMimeType = class
  private
  { Private declarations }
    class function StringToAnsi7(const Text: string): String;
  public
  { Public declarations }
    class function GetMimeContentTypeFromBuffer(Content: Pointer; Len: NativeInt; const DefaultContentType: String): String;
    class function GetMimeContentType(Content: Pointer; Len: NativeInt; const FileName: TFileName): String;
    class function GetMimeContentTypeHeader(const Content: RawByteString; const FileName: TFileName): String;
  end;

type
  TBase64 = class(TMimeType)
  private
  { Private declarations }
  public
  { Public declarations }
    class function ToEncode(Value: Variant; ReadOrWrite: TBinaryMode = TBinaryMode.Read) : String;
  end;

implementation

class function TMimeType.StringToAnsi7(const Text: string): String;
{$IFDEF UNICODE}
var
  I: NativeInt;
begin
  SetString(Result, nil, Length(Text));
  for I := 0 to Length(Text)-1 do
    PByteArray(result)[I] := PWordArray(Text)[I];
end;
{$ELSE}
begin
  Result := Text;
end;
{$ENDIF}

class function TMimeType.GetMimeContentTypeFromBuffer(Content: Pointer; Len: NativeInt; const DefaultContentType: String): String;
begin // see http://www.garykessler.net/library/file_sigs.html for magic numbers
  result := DefaultContentType;
  if (Content<>nil) and (Len>4) then
    case PCardinal(Content)^ of
    $04034B50: result := 'application/zip'; // 50 4B 03 04
    $46445025: result := 'application/pdf'; //  25 50 44 46 2D 31 2E
    $21726152: result := 'application/x-rar-compressed'; // 52 61 72 21 1A 07 00
    $AFBC7A37: result := 'application/x-7z-compressed';  // 37 7A BC AF 27 1C
    $694C5153: result := 'application/x-sqlite3'; // SQlite format 3 = 53 51 4C 69
    $75B22630: result := 'audio/x-ms-wma'; // 30 26 B2 75 8E 66
    $9AC6CDD7: result := 'video/x-ms-wmv'; // D7 CD C6 9A 00 00
    $474E5089: result := 'image/png'; // 89 50 4E 47 0D 0A 1A 0A
    $38464947: result := 'image/gif'; // 47 49 46 38
    $46464F77: result := 'application/font-woff'; // wOFF in BigEndian
    $A3DF451A: result := 'video/webm'; // 1A 45 DF A3 MKV Matroska stream file
    $002A4949, $2A004D4D, $2B004D4D:
      result := 'image/tiff'; // 49 49 2A 00 or 4D 4D 00 2A or 4D 4D 00 2B
    $46464952: if Len>16 then // RIFF
      case PCardinalArray(Content)^[2] of
      $50424557: result := 'image/webp';
      $20495641: if PCardinalArray(Content)^[3]=$5453494C then
        result := 'video/x-msvideo'; // Windows Audio Video Interleave file
      end;
    $E011CFD0: // Microsoft Office applications D0 CF 11 E0=DOCFILE
      if Len>600 then
      case PWordArray(Content)^[256] of // at offset 512
        $A5EC: result := 'application/msword'; // EC A5 C1 00
        $FFFD: // FD FF FF
          case PByteArray(Content)^[516] of
            $0E,$1C,$43: result := 'application/vnd.ms-powerpoint';
            $10,$1F,$20,$22,$23,$28,$29: result := 'application/vnd.ms-excel';
          end;
      end;
    $5367674F:
      if Len>14 then // OggS
        if (PCardinalArray(Content)^[1]=$00000200) and
           (PCardinalArray(Content)^[2]=$00000000) and
           (PWordArray(Content)^[6]=$0000) then
          result := 'video/ogg';
    $1C000000:
      if Len>12 then
        if PCardinalArray(Content)^[1]=$70797466 then  // ftyp
          case PCardinalArray(Content)^[2] of
            $6D6F7369, // isom: ISO Base Media file (MPEG-4) v1
            $3234706D: // mp42: MPEG-4 video/QuickTime file
              result := 'video/mp4';
            $35706733: // 3gp5: MPEG-4 video files
              result := 'video/3gpp';
          end;
    else
      case PCardinal(Content)^ and $00ffffff of
        $685A42: result := 'application/bzip2'; // 42 5A 68
        $088B1F: result := 'application/gzip'; // 1F 8B 08
        $492049: result := 'image/tiff'; // 49 20 49
        $FFD8FF: result := JPEG_CONTENT_TYPE; // FF D8 FF DB/E0/E1/E2/E3/E8
        else
          case PWord(Content)^ of
            $4D42: result := 'image/bmp'; // 42 4D
          end;
      end;
    end;
end;

class function TMimeType.GetMimeContentType(Content: Pointer; Len: NativeInt; const FileName: TFileName): String;
begin
  if FileName<>'' then begin // file extension is more precise -> check first
    Result := LowerCase(Self.StringToAnsi7(ExtractFileExt(FileName)));
    case PosEx(copy(result,2,4),
      'png,gif,tiff,jpg,jpeg,bmp,doc,htm,html,css,js,ico,wof,txt,svg,'+
     // 1   5   9    14  18   23  27  31  35   40  44 47  51  55  59
      'atom,rdf,rss,webp,appc,mani,docx,xml,json,woff,ogg,ogv,mp4,m2v,'+
     // 63  68  72  76   81   86   91   96  100  105  110 114 118 122
      'm2p,mp3,h264,text,log,gz,webm,mkv,rar,7z') of
     // 126 130 134 139  144 148 151 156 160 164
      1:           result := 'image/png';
      5:           result := 'image/gif';
      9:           result := 'image/tiff';
      14,18:       result := JPEG_CONTENT_TYPE;
      23:          result := 'image/bmp';
      27,91:       result := 'application/msword';
      31,35:       result := HTML_CONTENT_TYPE;
      40:          result := 'text/css';
      44:          result := 'application/javascript';
      // text/javascript and application/x-javascript are obsolete (RFC 4329)
      47:          result := 'image/x-icon';
      51,105:      result := 'application/font-woff';
      55,139,144:  result := TEXT_CONTENT_TYPE;
      59:          result := 'image/svg+xml';
      63,68,72,96: result := XML_CONTENT_TYPE;
      76:          result := 'image/webp';
      81,86:       result := 'text/cache-manifest';
      100:         result := JSON_CONTENT_TYPE_VAR;
      110,114:     result := 'video/ogg';  // RFC 5334
      118:         result := 'video/mp4';  // RFC 4337 6381
      122,126:     result := 'video/mp2';
      130:         result := 'audio/mpeg'; // RFC 3003
      134:         result := 'video/H264'; // RFC 6184
      148:         result := 'application/gzip';
      151,156:     result := 'video/webm';
      160:         result := 'application/x-rar-compressed';
      164:         result := 'application/x-7z-compressed';
      else
        result := Self.GetMimeContentTypeFromBuffer(Content,Len,'application/'+Copy(Result,2,20));
    end;
  end else
    result := Self.GetMimeContentTypeFromBuffer(Content, Len, BINARY_CONTENT_TYPE);
end;

class function TMimeType.GetMimeContentTypeHeader(const Content: RawByteString; const FileName: TFileName): String;
begin
  result := HEADER_CONTENT_TYPE + Self.GetMimeContentType(Pointer(Content),length(Content),FileName);
end;

{ TBase64 }

class function TBase64.ToEncode(Value: Variant; ReadOrWrite: TBinaryMode = TBinaryMode.Read): String;
var
  MemoryStream, BinaryStream: TMemoryStream;
  StringStream: TStringStream;
  MimeType, StrStream: String;
  MemPointer, Buffer: Pointer;
  HexStr: String;
begin
  HexStr := Value;
  Buffer := AllocMem(Length(HexStr));
  HexToBin(PWideChar(HexStr), Buffer, Length(HexStr));
  BinaryStream := TMemoryStream.Create();
  try
    BinaryStream.Write(Buffer^, Length(HexStr));
    BinaryStream.Position := 0;
    MemoryStream := TMemoryStream.Create;
    try
      MemoryStream.LoadFromStream(BinaryStream);
      MemoryStream.Position := 0;
      StringStream := TStringStream.Create;
      try
        MemPointer := AllocMem(MemoryStream.Size);
        MemoryStream.Seek(0, soBeginning);
        MemoryStream.Read(MemPointer^, MemoryStream.Size);
        MimeType := TMimeType.GetMimeContentTypeFromBuffer(MemPointer, MemoryStream.Size, '');
        MemoryStream.Seek(0, soBeginning);
        TNetEncoding.Base64.Encode(MemoryStream, StringStream);
        if MimeType <> EmptyStr then
        begin
          StrStream := 'data:' + MimeType + ';base64,' + TString.RemoveSpecialChars(StringStream.DataString);
          Result := StrStream;
        end
        else
          Result := Trim(HexStr);
          //Leitura
          //ResultArray.AddKeyValue(SQL.Query.Fields[I].DisplayName, QuotedStr(StrStream));
          //Grava��o
          //ResultArray.AddKeyValue(SQL.Query.Fields[I].DisplayName, TEncoding.Default.GetString(TNetEncoding.Base64.Decode(TEncoding.Default.GetBytes(StringStream.DataString))));

          //Reobten��o
          //ResultArray.AddKeyValue(SQL.Query.Fields[I].DisplayName, QuotedStr(SQL.Query.Fields[I].AsString));
          {
          //Grava��o
          MemoryStream := TMemoryStream.Create;
          try
            TBlobField(SQL.Query.Fields[I]).SaveToStream(MemoryStream);
            MemoryStream.Seek(0, soBeginning);
            SetLength(StrStream, MemoryStream.Size * 2);
            BinToHex(MemoryStream.Memory, PChar(StrStream), MemoryStream.Size);
            ResultArray.AddKeyValue(SQL.Query.Fields[I].DisplayName, QuotedStr(StrStream));
          finally
            MemoryStream.Free;
          end;
          }

      finally
        StringStream.Free;
      end;
    finally
      MemoryStream.Free;
    end;
  finally
    FreeMemory(Buffer);
    BinaryStream.Free;
  end;
end;

end.