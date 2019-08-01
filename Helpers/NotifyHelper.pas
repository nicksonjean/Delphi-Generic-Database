unit NotifyHelper;

interface

uses
  System.Classes,
  System.SysUtils;

  { Classe TEventComponent Herdada de TComponent }
type
  TEventComponent = class(TComponent)
  protected
    { Protected declarations }
    FAnon: TProc;
    procedure Notify(Sender: TObject);
    class function MakeComponent(const AOwner: TComponent; const AProc: TProc): TEventComponent;
  public
    { Public declarations }
    class function NotifyEvent(const AOwner: TComponent; const AProc: TProc): TNotifyEvent;
  end;

implementation

{ TEventComponent }

class function TEventComponent.MakeComponent(const AOwner: TComponent; const AProc: TProc): TEventComponent;
begin
  Result:= TEventComponent.Create(AOwner);
  Result.FAnon:= AProc;
end;

procedure TEventComponent.Notify(Sender: TObject);
begin
  FAnon();
end;

class function TEventComponent.NotifyEvent(const AOwner: TComponent; const AProc: TProc): TNotifyEvent;
begin
  Result:= MakeComponent(AOwner, AProc).Notify;
end;

end.
