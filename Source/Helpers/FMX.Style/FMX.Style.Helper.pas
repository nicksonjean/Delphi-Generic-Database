(*
Source - https://stackoverflow.com/a/79858286
https://stackoverflow.com/questions/36498119/how-to-apply-a-custom-style-to-a-custom-firemonkey-component-using-delphi-seattl
Posted by alitrun, modified by community. See post 'Timeline' for change history
Retrieved 2026-04-09, License - CC BY-SA 4.0
*)

unit FMX.Style.Helper;

{ Delphi FMX helper that loads a .style from resource (RT_RCDATA works on any platform, not only Windows) and keep alive for
  the entire application lifetime.
  Every object inside the style that has a StyleName is automatically registered in the global FMX style pool,
  so any control can later resolve it with a StyleLookup, without subclassing or overriding GetStyleObject.
  It works together with other styles if a stylebook is attached to the form or no stylebook at all.

  TFontResourceHelper: loads a TTF font embedded as RCDATA and installs it as a
  per-user font (%LOCALAPPDATA%\Microsoft\Windows\Fonts + HKCU registry key).
  DirectWrite (used by FMX) natively scans this location, so no admin rights are
  needed and the font is visible immediately on the next DirectWrite font collection
  query. Call RegisterFontFromResource before Application.Initialize.
}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, FMX.Types, FMX.Styles, System.Types;

type
  TResourceStyleHelper = class
  protected
    // one root for all forms, each TFmxObject contains a ".style" (style container) with multiple styles
    class var fInternalStyles: TObjectDictionary<string, TFmxObject>;
    class function LoadResourceStylesGlobal(const ResourceName: string; const Instance: HINST): TFmxObject;
  public
    class destructor Destroy;
    //  Call once early with the RCDATA resource name that contains the style file.
    class function RegisterResourceStylesGlobal(const ResourceName: string; const Instance: HINST = 0): TFmxObject;
  end;

  TFontResourceHelper = class
  public
    /// Installs a TTF embedded as RCDATA as a per-user font so DirectWrite (FMX)
    /// can resolve it without admin rights. Copies the file to
    /// %LOCALAPPDATA%\Microsoft\Windows\Fonts\ and writes the HKCU registry key.
    /// Call BEFORE Application.Initialize so the font is in the DirectWrite
    /// collection from the very first query.
    /// AResName must match the .rc identifier, e.g. 'BOOTSTRAP_ICONS'.
    class procedure RegisterFontFromResource(const AResName: string;
      const AInstance: HINST = 0);
  end;

implementation

{$IFDEF MSWINDOWS}
uses
  Winapi.Windows,
  Winapi.Messages,
  System.Win.Registry,
  System.IOUtils;

type
  // Minimal DirectWrite interfaces — declared locally to avoid dependency on
  // Winapi.DWrite (not available in all Delphi versions).
  IDWriteFontCollection = interface(IUnknown)
    ['{A84CEE02-3EEA-4EEE-A827-87C1A02A0FCC}']
  end;

  // Only the first method of IDWriteFactory (after IUnknown) is declared here.
  // Per dwrite.h, GetSystemFontCollection sits at vtable slot 3 — immediately
  // after QueryInterface(0), AddRef(1) and Release(2).
  IDWriteFactory = interface(IUnknown)
    ['{B859EE5A-D838-4B5B-A2E8-1ADC7D93DB48}']
    function GetSystemFontCollection(out fontCollection: IDWriteFontCollection;
      checkForUpdates: BOOL): HRESULT; stdcall;
  end;

  TDWriteCreateFactoryFn = function(factoryType: DWORD; const riid: TGUID;
    out factory: IUnknown): HRESULT; stdcall;

// Forces the DirectWrite *shared* factory to discard its cached font collection
// and rebuild it from the current system state (user + system fonts).
// FMX uses DWRITE_FACTORY_TYPE_SHARED (0), so the same factory instance is
// targeted and subsequent calls from FMX will see the freshly installed font.
procedure RefreshDirectWriteFontCollection;
const
  DWRITE_FACTORY_TYPE_SHARED = 0;
var
  LLib: HMODULE;
  LCreateFactory: TDWriteCreateFactoryFn;
  LUnk: IUnknown;
  LFactory: IDWriteFactory;
  LCollection: IDWriteFontCollection;
begin
  LLib := LoadLibrary('dwrite.dll');
  if LLib = 0 then Exit;
  try
    @LCreateFactory := GetProcAddress(LLib, 'DWriteCreateFactory');
    if not Assigned(LCreateFactory) then Exit;
    if Failed(LCreateFactory(DWRITE_FACTORY_TYPE_SHARED,
                             IDWriteFactory,
                             LUnk)) then Exit;
    if not Supports(LUnk, IDWriteFactory, LFactory) then Exit;
    LFactory.GetSystemFontCollection(LCollection, True {checkForUpdates});
  finally
    FreeLibrary(LLib);
  end;
end;
{$ENDIF}

{ TFontResourceHelper }

class procedure TFontResourceHelper.RegisterFontFromResource(
  const AResName: string; const AInstance: HINST = 0);
{$IFDEF MSWINDOWS}
const
  REG_FONTS_KEY = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts';
var
  LStream: TResourceStream;
  LFontsDir: string;
  LFontPath: string;
  LInstance: HINST;
  LReg: TRegistry;
begin
  LInstance := AInstance;
  if LInstance = 0 then
    LInstance := HInstance;

  // %LOCALAPPDATA%\Microsoft\Windows\Fonts\ — DirectWrite scans this natively
  LFontsDir := TPath.Combine(GetEnvironmentVariable('LOCALAPPDATA'),
                              'Microsoft\Windows\Fonts');
  ForceDirectories(LFontsDir);
  LFontPath := TPath.Combine(LFontsDir, LowerCase(AResName) + '.ttf');

  if not TFile.Exists(LFontPath) then
  begin
    LStream := TResourceStream.Create(LInstance, AResName, RT_RCDATA);
    try
      LStream.SaveToFile(LFontPath);
    finally
      LStream.Free;
    end;
  end;

  // HKCU registry entry — lets DirectWrite find the font without a reboot
  LReg := TRegistry.Create(KEY_SET_VALUE);
  try
    LReg.RootKey := HKEY_CURRENT_USER;
    if LReg.OpenKey(REG_FONTS_KEY, False) then
    try
      LReg.WriteString(AResName + ' (TrueType)', LFontPath);
    finally
      LReg.CloseKey;
    end;
  finally
    LReg.Free;
  end;

  AddFontResourceEx(PChar(LFontPath), 0, nil);

  // Force the DirectWrite shared factory to rebuild its font collection so
  // the newly installed font is visible to FMX text rendering immediately.
  RefreshDirectWriteFontCollection;

  SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
end;
{$ELSE}
begin
end;
{$ENDIF}

{ TResourceStyleHelper }

class destructor TResourceStyleHelper.Destroy;
begin
  FreeAndNil(fInternalStyles);  // values are freed automatically
end;

class function TResourceStyleHelper.RegisterResourceStylesGlobal(const ResourceName: string;
    const Instance: HINST = 0): TFmxObject;
begin
  var ResHandle := Instance;
  if ResHandle = 0 then
    ResHandle := HInstance;

  Result := LoadResourceStylesGlobal(ResourceName, ResHandle);
  Assert(Result <> nil, Format('Style resource "%s" not found', [ResourceName]));
end;

class function TResourceStyleHelper.LoadResourceStylesGlobal(const ResourceName: string; const Instance: HINST): TFmxObject;
var
  RootStyles: TFmxObject;
begin
  if fInternalStyles = nil then
    fInternalStyles := TObjectDictionary<string, TFmxObject>.Create([doOwnsValues]);

  if fInternalStyles.TryGetValue(ResourceName, RootStyles) then Exit(RootStyles);

  // Load .style file from resource
  try
    RootStyles := TStyleStreaming.LoadFromResource(Instance, ResourceName, RT_RCDATA);
    { Keep RootStyles alive for the entire application lifetime.  While it exists, every object that has a StyleName stays
      registered in the global FMX pool and is discoverable by StyleLookup. }
  except
    RootStyles := nil;
  end;

  fInternalStyles.Add(ResourceName, RootStyles);
  Result := RootStyles;
end;

end.