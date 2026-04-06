unit EventDriven.Paint;

interface

uses
  System.Classes,
  System.Types,
  FMX.Graphics;

type
  TPaintEvent = procedure(Sender: TObject; Canvas: TCanvas; const ARect: TRectF) of object;
  TNotifyPaintEventReference = reference to procedure(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);

function DelegatePaintEvent(Owner: TComponent; Proc: TNotifyPaintEventReference): TPaintEvent;

type
  TNotifyPaintEventWrapper = class(TComponent)
  private
    FProc: TNotifyPaintEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyPaintEventReference); reintroduce;
  published
    procedure PaintEvent(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
  end;

implementation

{ TNotifyPaintEventWrapper }

constructor TNotifyPaintEventWrapper.Create(Owner: TComponent; Proc: TNotifyPaintEventReference);
begin
  inherited Create(Owner);
  FProc := Proc;
end;

procedure TNotifyPaintEventWrapper.PaintEvent(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
  FProc(Sender, Canvas, ARect);
end;

function DelegatePaintEvent(Owner: TComponent; Proc: TNotifyPaintEventReference): TPaintEvent;
begin
  Result := TNotifyPaintEventWrapper.Create(Owner, Proc).PaintEvent;
end;

end.
