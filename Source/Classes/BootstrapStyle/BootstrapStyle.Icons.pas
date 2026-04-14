unit BootstrapStyle.Icons;

{
  Bootstrap Icons (font) — names match the official bootstrap-icons set.
  Glyph codes from twbs/icons font/bootstrap-icons.json (decimal code points).
}

interface

uses
  System.SysUtils,
  System.Character,
  System.Generics.Collections;

type
  TBootstrapIcons = class
  private
    class var FMap: TDictionary<string, Integer>;
    class procedure Register(const AName: string; ACode: Integer); static;
    class constructor Create;
    class destructor Destroy;
  public
    const FontFamily = 'bootstrap-icons';

    class function NormalizeName(const AName: string): string; static;
    { Single-character glyph for TLabel / icon-only buttons (bootstrap-icons.ttf). }
    class function Glyph(const ABootstrapIconName: string): string; static;
    { Icon + two spaces + caption (same font must be bootstrap-icons for the whole string). }
    class function SpacedIcon(const ABootstrapIconName, ACaption: string): string; static;
  end;

implementation

uses
  System.StrUtils;

{ TBootstrapIcons }

class constructor TBootstrapIcons.Create;
begin
  FMap := TDictionary<string, Integer>.Create(256);
  { --- Navigation / UI (demo + frames) --- }
  Register('arrow-clockwise', 61718);
  Register('arrow-left-right', 61739);
  Register('ban', 63158);
  Register('braces', 61897);
  Register('calculator', 61920);
  Register('check-lg', 63027);
  Register('chevron-bar-left', 62070);
  Register('chevron-bar-right', 62071);
  Register('chevron-left', 62084);
  Register('chevron-right', 62085);
  Register('code-slash', 62150);
  Register('database-fill', 63678);
  Register('download', 62218);
  Register('envelope', 62255);
  Register('floppy', 63448);
  Register('folder2-open', 62424);
  Register('house', 62501);
  Register('lightning-charge', 62573);
  Register('lightning-charge-fill', 62572);
  Register('pencil', 62667);
  Register('play-fill', 62708);
  Register('plug-fill', 62710);
  Register('plus-lg', 63053);
  Register('skip-end', 62808);
  Register('skip-start', 62820);
  Register('speedometer2', 62848);
  Register('table', 62890);
  Register('trash', 62942);
  Register('upload', 62979);
  Register('x-lg', 63065);
end;

class destructor TBootstrapIcons.Destroy;
begin
  FMap.Free;
end;

class procedure TBootstrapIcons.Register(const AName: string; ACode: Integer);
begin
  FMap.AddOrSetValue(AName, ACode);
end;

class function TBootstrapIcons.NormalizeName(const AName: string): string;
begin
  Result := LowerCase(Trim(StringReplace(AName, '_', '-', [rfReplaceAll])));
end;

class function TBootstrapIcons.Glyph(const ABootstrapIconName: string): string;
var
  Code: Integer;
begin
  if not FMap.TryGetValue(NormalizeName(ABootstrapIconName), Code) then
    Exit('');
  if (Code < 0) or (Code > $10FFFF) then
    Exit('');
  if Code > $FFFF then
    Result := Char.ConvertFromUtf32(Code)
  else
    Result := Char(Word(Code));
end;

class function TBootstrapIcons.SpacedIcon(const ABootstrapIconName, ACaption: string): string;
var
  G: string;
begin
  G := Glyph(ABootstrapIconName);
  if G = '' then
    Exit(ACaption);
  if ACaption = '' then
    Exit(G);
  Result := G + '  ' + ACaption;
end;

end.
