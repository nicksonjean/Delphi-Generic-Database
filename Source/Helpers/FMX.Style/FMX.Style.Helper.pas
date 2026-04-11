(*
Source - https://stackoverflow.com/a/79858286
Posted by alitrun, modified by community. See post 'Timeline' for change history
Retrieved 2026-04-09, License - CC BY-SA 4.0
*)

unit FMX.Style.Helper;

{ Delphi FMX helper that loads a .style from resource (RT_RCDATA works on any platform, not only Windows) and keep alive for
  the entire application lifetime.
  Every object inside the style that has a StyleName is automatically registered in the global FMX style pool,
  so any control can later resolve it with a StyleLookup, without subclassing or overriding GetStyleObject.
  It works together with other styles if a stylebook is attached to the form or no stylebook at all.
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

implementation

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