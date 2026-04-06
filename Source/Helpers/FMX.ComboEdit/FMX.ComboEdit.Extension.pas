unit FMX.ComboEdit.Extension;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  FMX.StdCtrls,
  FMX.Types,
  FMX.Controls,
  FMX.ComboEdit,
  FMX.ComboEdit.Style,
  FMX.Controls.Presentation,
  FMX.Controls.Model,
  FMX.Presentation.Factory,
  FMX.Objects,
  EventDelegate;

implementation

type
  // Uses 'editstyle' instead of 'comboeditstyle' so borders, focus, and hover
  // are 100% identical to TEdit — the style system handles everything.
  // The dropdown button is injected manually in ApplyStyle.
  TStyledComboEditEditStyle = class(TStyledComboEdit)
  private
    FDropBtn: TButton;
    procedure ApplyDropDownButtonStyle;
  protected
    function GetDefaultStyleLookupName: string; override;
    // Override BOTH GetStyleObject overloads — TStyledPresentation.GetStyleObject
    // delegates to PresentedControl (TComboEdit) which would use 'comboeditstyle'.
    // We bypass that and use 'editstyle' via TStyledControl.LookupStyleObject.
    function GetStyleObject: TFmxObject; override;
    function GetStyleObject(const Clone: Boolean): TFmxObject; override;
    procedure ApplyStyle; override;
    procedure FreeStyle; override;
  end;

  TStyleComboEditEditStyleProxy = class(TPresentationProxy)
  protected
    function CreateReceiver: TObject; override;
  end;

{ TStyledComboEditEditStyle }

function TStyledComboEditEditStyle.GetDefaultStyleLookupName: string;
begin
  Result := 'editstyle';
end;

function TStyledComboEditEditStyle.GetStyleObject: TFmxObject;
begin
  Result := GetStyleObject(True);
end;

function TStyledComboEditEditStyle.GetStyleObject(const Clone: Boolean): TFmxObject;
begin
  Result := LookupStyleObject(Self, GetStyleContext, Scene, '', 'editstyle', '', Clone);
end;

procedure TStyledComboEditEditStyle.ApplyStyle;
begin
  inherited;
  ApplyDropDownButtonStyle;
end;

procedure TStyledComboEditEditStyle.FreeStyle;
begin
  FDropBtn := nil;
  inherited;
end;

procedure TStyledComboEditEditStyle.ApplyDropDownButtonStyle;
const
  BtnWidth = 20;
  HookTag  = 'DGD.ComboEdit.DropBtnHooked';
var
  PrevClick: TNotifyEvent;
begin
  // Create the button once; survive repeated ApplyStyle calls.
  if FDropBtn = nil then
  begin
    FDropBtn := TButton.Create(Self);
    FDropBtn.Stored   := False;
    FDropBtn.Parent   := Self;
  end;

  FDropBtn.Cursor      := crArrow;
  FDropBtn.Width       := BtnWidth;
  FDropBtn.Align       := TAlignLayout.Right;
  FDropBtn.StyleLookup := 'dropdowneditbutton';

  // Hook click once; guard against re-hooking on every ApplyStyle rebuild.
  if not SameText(FDropBtn.TagString, HookTag) then
  begin
    FDropBtn.TagString := HookTag;
    PrevClick := FDropBtn.OnClick;
    FDropBtn.OnClick := DelegateEvent(FDropBtn,
      procedure(Sender: TObject)
      begin
        if PresentedControl is TComboEdit then
          TComboEdit(PresentedControl).DropDown;
        if Assigned(PrevClick) then
          PrevClick(Sender);
      end);
  end;

  // Always bring to front so the button isn't painted under the edit border.
  FDropBtn.BringToFront;
end;

{ TStyleComboEditEditStyleProxy }

function TStyleComboEditEditStyleProxy.CreateReceiver: TObject;
begin
  Result := TStyledComboEditEditStyle.Create(nil, Model, PresentedControl);
end;

procedure RegisterComboEditPresentation(const AName: string);
begin
  TPresentationProxyFactory.Current.Unregister(AName);
  TPresentationProxyFactory.Current.Register(AName, TStyleComboEditEditStyleProxy);
end;

initialization
  RegisterComboEditPresentation('ComboEdit-style');

finalization
  try
    TPresentationProxyFactory.Current.Unregister('ComboEdit-style');
  except
  end;

end.
