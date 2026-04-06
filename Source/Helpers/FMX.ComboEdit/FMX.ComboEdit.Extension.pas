unit FMX.ComboEdit.Extension;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  FMX.Types,
  FMX.Controls,
  FMX.ComboEdit,
  FMX.ComboEdit.Style,
  FMX.Controls.Presentation,
  FMX.Controls.Model,
  FMX.Presentation.Factory,
  FMX.Objects,
  FMX.Graphics,
  EventDelegate;

type
  TComboEditExtension = class helper for TComboEdit
  public
    procedure ApplyEditStyleRuntime;
  end;

implementation

type
  TStyledComboEditEditStyle = class(TStyledComboEdit)
  protected
    procedure ApplyStyle; override;
  end;

  TStyleComboEditEditStyleProxy = class(TPresentationProxy)
  protected
    function CreateReceiver: TObject; override;
  end;

  TComboEditEditStyleBehavior = class(TComponent)
  private
    FCombo: TComboEdit;
    FDropBtn: TRectangle;
    FSepLine: TRectangle;
    FArrow: TPath;
    FEventsHooked: Boolean;
    FApplying: Boolean;
    FApplied: Boolean;
    procedure DropDownButtonClick(Sender: TObject);
    procedure DropDownButtonMouseEnter(Sender: TObject);
    procedure DropDownButtonMouseLeave(Sender: TObject);
    procedure UpdateDropDownButtonBounds;
    procedure SetDropBtnHover(Hovered: Boolean);
  public
    procedure Attach(ACombo: TComboEdit);
  end;

{ TComboEditEditStyleBehavior }

procedure TComboEditEditStyleBehavior.Attach(ACombo: TComboEdit);
const
  DropBtnWidth = 20;
var
  PrevOnResize: TNotifyEvent;
  PrevOnMouseLeave: TNotifyEvent;
  StyleChanged: Boolean;
begin
  if ACombo = nil then
    Exit;

  FCombo := ACombo;

  if FApplying then
    Exit;

  FApplying := True;
  try
    // Keep base Edit visuals (guarded to avoid style recursion).
    // Applying style inside a presentation ApplyStyle cycle may not rebuild borders;
    // queue the ApplyStyleLookup to the next UI cycle.
    StyleChanged := not SameText(FCombo.StyleLookup, 'editstyle');
    if StyleChanged then
      FCombo.StyleLookup := 'editstyle';
    FCombo.Cursor := crIBeam;
    if StyleChanged then
      TThread.Queue(nil,
        procedure
        begin
          if (FCombo <> nil) and not FApplying then
            FCombo.ApplyStyleLookup;
        end);

    if FDropBtn = nil then
    begin
      FDropBtn := TRectangle.Create(FCombo);
      FDropBtn.Parent := FCombo;
      FDropBtn.Align := TAlignLayout.None;
      FDropBtn.Width := DropBtnWidth;
      FDropBtn.Height := FCombo.Height;
      FDropBtn.Margins.Rect := TRectF.Empty;
      FDropBtn.Padding.Rect := TRectF.Empty;
      FDropBtn.Stored := False;
      FDropBtn.HitTest := True;
      FDropBtn.XRadius := 0;
      FDropBtn.YRadius := 0;
      FDropBtn.Stroke.Kind := TBrushKind.None;
      FDropBtn.Fill.Kind := TBrushKind.Solid;
      FDropBtn.Fill.Color := $00000000;
      FDropBtn.Cursor := crArrow;
      FDropBtn.OnClick := DropDownButtonClick;
      FDropBtn.OnMouseEnter := DropDownButtonMouseEnter;
      FDropBtn.OnMouseLeave := DropDownButtonMouseLeave;
      FDropBtn.BringToFront;

      // Separator (covers any internal ComboEdit rendering on hover)
      FSepLine := TRectangle.Create(FCombo);
      FSepLine.Parent := FCombo;
      FSepLine.Name := 'DropBtnSepLine';
      FSepLine.Stored := False;
      FSepLine.HitTest := False;
      FSepLine.Align := TAlignLayout.None;
      FSepLine.Width := 1;
      FSepLine.Fill.Kind := TBrushKind.Solid;
      FSepLine.Fill.Color := $00000000;
      FSepLine.Stroke.Kind := TBrushKind.None;
      FSepLine.BringToFront;

      FArrow := TPath.Create(FDropBtn);
      FArrow.Parent := FDropBtn;
      FArrow.Name := 'DropBtnArrow';
      FArrow.Stored := False;
      FArrow.HitTest := False;
      FArrow.Align := TAlignLayout.Center;
      FArrow.Width := 10;
      FArrow.Height := 10;
      FArrow.WrapMode := TPathWrapMode.Fit;
      FArrow.Data.Data := 'M 2 4 L 6 8 L 10 4';
      FArrow.Fill.Kind := TBrushKind.None;
      FArrow.Stroke.Kind := TBrushKind.Solid;
      FArrow.Stroke.Thickness := 1.2;
      FArrow.Stroke.Color := $FF404040;
    end;

    // Chain events using existing Delegate pattern
    if not FEventsHooked then
    begin
      PrevOnResize := FCombo.OnResize;
      PrevOnMouseLeave := FCombo.OnMouseLeave;

      FCombo.OnResize := DelegateEvent(FCombo,
        procedure(Sender: TObject)
        begin
          UpdateDropDownButtonBounds;
          if Assigned(PrevOnResize) then
            PrevOnResize(Sender);
        end);

      FCombo.OnMouseLeave := DelegateEvent(FCombo,
        procedure(Sender: TObject)
        begin
          SetDropBtnHover(False);
          if Assigned(PrevOnMouseLeave) then
            PrevOnMouseLeave(Sender);
        end);

      FEventsHooked := True;
    end;

    UpdateDropDownButtonBounds;
    SetDropBtnHover(False);
    FApplied := True;
  finally
    FApplying := False;
  end;
end;

procedure TComboEditEditStyleBehavior.DropDownButtonClick(Sender: TObject);
begin
  if FCombo <> nil then
    FCombo.DropDown;
end;

procedure TComboEditEditStyleBehavior.DropDownButtonMouseEnter(Sender: TObject);
begin
  SetDropBtnHover(True);
end;

procedure TComboEditEditStyleBehavior.DropDownButtonMouseLeave(Sender: TObject);
begin
  SetDropBtnHover(False);
end;

procedure TComboEditEditStyleBehavior.SetDropBtnHover(Hovered: Boolean);
begin
  if (FDropBtn = nil) or (FSepLine = nil) then
    Exit;

  if Hovered then
  begin
    FDropBtn.Fill.Color := $330078D7;
    FSepLine.Fill.Color := $FF0078D7;
  end
  else
  begin
    FDropBtn.Fill.Color := $00000000;
    FSepLine.Fill.Color := $00000000;
  end;
end;

procedure TComboEditEditStyleBehavior.UpdateDropDownButtonBounds;
var
  W: Single;
begin
  if (FCombo = nil) or (FDropBtn = nil) or (FSepLine = nil) then
    Exit;

  W := FDropBtn.Width;
  if W < 16 then
    W := 16;
  FDropBtn.Width := W;

  FDropBtn.SetBounds(FCombo.Width - FDropBtn.Width, 0, FDropBtn.Width, FCombo.Height);
  FDropBtn.BringToFront;

  FSepLine.SetBounds(FCombo.Width - FDropBtn.Width, 0, 1, FCombo.Height);
  FSepLine.BringToFront;

  FCombo.Padding.Right := FDropBtn.Width + 6;
end;

{ TComboEditExtension }

procedure TComboEditExtension.ApplyEditStyleRuntime;
var
  Behavior: TComboEditEditStyleBehavior;
begin
  Behavior := FindComponent('ComboEditEditStyleBehavior') as TComboEditEditStyleBehavior;
  if Behavior = nil then
  begin
    Behavior := TComboEditEditStyleBehavior.Create(Self);
    Behavior.Name := 'ComboEditEditStyleBehavior';
  end;
  if not Behavior.FApplied then
    Behavior.Attach(Self)
  else
    Behavior.UpdateDropDownButtonBounds;
end;

{ TStyledComboEditEditStyle }

procedure TStyledComboEditEditStyle.ApplyStyle;
begin
  inherited;

  if (PresentedControl is TComboEdit) then
    TComboEdit(PresentedControl).ApplyEditStyleRuntime;
end;

{ TStyleComboEditEditStyleProxy }

function TStyleComboEditEditStyleProxy.CreateReceiver: TObject;
begin
  Result := TStyledComboEditEditStyle.Create(nil, Model, PresentedControl);
end;

procedure RegisterComboEditPresentation(const AName: string);
begin
  // Match FMX.Edit.Extension behavior: replace existing presentation proxy
  TPresentationProxyFactory.Current.Unregister(AName);
  TPresentationProxyFactory.Current.Register(AName, TStyleComboEditEditStyleProxy);
end;

initialization
  // Replace default TComboEdit presenter with our proxy (same pattern as Edit)
  RegisterComboEditPresentation('ComboEdit-style');

finalization
  try
    TPresentationProxyFactory.Current.Unregister('ComboEdit-style');
  except
  end;

end.

