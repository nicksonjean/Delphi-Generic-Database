unit EventDriven.GridBindings;

interface

uses
  System.Classes,
  System.RTTI,
  FMX.Grid;

type
  TOnGetValue = procedure(Sender: TObject; const ACol, ARow: Integer; var Value: System.Rtti.TValue) of object;
  TOnSetValue = procedure(Sender: TObject; const ACol, ARow: Integer; const Value: System.Rtti.TValue) of object;
  TPresenterNameChoosingEvent = procedure(Sender: TObject; var PresenterName: string) of object;

  TNotifyOnGetValueEventReference = reference to procedure(Sender: TObject; const ACol, ARow: Integer; var Value: System.Rtti.TValue);
  TNotifyOnSetValueEventReference = reference to procedure(Sender: TObject; const ACol, ARow: Integer; const Value: System.Rtti.TValue);
  TNotityOnPresentationNameChoosing = reference to procedure(Sender: TObject; var PresenterName: string);

function DelegateOnGetValueEvent(Owner: TComponent; Proc: TNotifyOnGetValueEventReference): TOnGetValue;
function DelegateOnSetValueEvent(Owner: TComponent; Proc: TNotifyOnSetValueEventReference): TOnSetValue;
function DelegateOnPresentationNameChoosing(Owner: TComponent; Proc: TNotityOnPresentationNameChoosing): TPresenterNameChoosingEvent;

type
  TNotifyOnGetValueEventReferenceWrapper = class(TComponent)
  private
    FProc: TNotifyOnGetValueEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyOnGetValueEventReference); reintroduce;
  published
    procedure OnGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: System.Rtti.TValue);
  end;

  TNotifyOnSetValueEventReferenceWrapper = class(TComponent)
  private
    FProc: TNotifyOnSetValueEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyOnSetValueEventReference); reintroduce;
  published
    procedure OnSetValue(Sender: TObject; const ACol, ARow: Integer; const Value: System.Rtti.TValue);
  end;

  TNotityOnPresentationNameChoosingReferenceWrapper = class(TComponent)
  private
    FProc: TNotityOnPresentationNameChoosing;
  public
    constructor Create(Owner: TComponent; Proc: TNotityOnPresentationNameChoosing); reintroduce;
  published
    procedure OnPresentationNameChoosing(Sender: TObject; var PresenterName: string);
  end;

implementation

{ TNotifyOnGetValueEventReferenceWrapper }

constructor TNotifyOnGetValueEventReferenceWrapper.Create(Owner: TComponent; Proc: TNotifyOnGetValueEventReference);
begin
  inherited Create(Owner);
  FProc := Proc;
end;

procedure TNotifyOnGetValueEventReferenceWrapper.OnGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: System.Rtti.TValue);
begin
  FProc(Sender, ACol, ARow, Value);
end;

function DelegateOnGetValueEvent(Owner: TComponent; Proc: TNotifyOnGetValueEventReference): TOnGetValue;
begin
  Result := TNotifyOnGetValueEventReferenceWrapper.Create(Owner, Proc).OnGetValue;
end;

{ TNotifyOnSetValueEventReferenceWrapper }

constructor TNotifyOnSetValueEventReferenceWrapper.Create(Owner: TComponent; Proc: TNotifyOnSetValueEventReference);
begin
  inherited Create(Owner);
  FProc := Proc;
end;

procedure TNotifyOnSetValueEventReferenceWrapper.OnSetValue(Sender: TObject; const ACol, ARow: Integer; const Value: System.Rtti.TValue);
begin
  FProc(Sender, ACol, ARow, Value);
end;

function DelegateOnSetValueEvent(Owner: TComponent; Proc: TNotifyOnSetValueEventReference): TOnSetValue;
begin
  Result := TNotifyOnSetValueEventReferenceWrapper.Create(Owner, Proc).OnSetValue;
end;

{ TNotityOnPresentationNameChoosingReferenceWrapper }

constructor TNotityOnPresentationNameChoosingReferenceWrapper.Create(Owner: TComponent; Proc: TNotityOnPresentationNameChoosing);
begin
  inherited Create(Owner);
  FProc := Proc;
end;

procedure TNotityOnPresentationNameChoosingReferenceWrapper.OnPresentationNameChoosing(Sender: TObject; var PresenterName: string);
begin
  FProc(Sender, PresenterName);
end;

function DelegateOnPresentationNameChoosing(Owner: TComponent; Proc: TNotityOnPresentationNameChoosing): TPresenterNameChoosingEvent;
begin
  Result := TNotityOnPresentationNameChoosingReferenceWrapper.Create(Owner, Proc).OnPresentationNameChoosing;
end;

end.
