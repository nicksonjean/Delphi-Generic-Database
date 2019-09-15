unit AnonumousThreadPool;

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
  System.Variants;

type
  TAnonumousThreadPool = class sealed(TObject)
  strict private
    FThreadList: TThreadList;
    procedure TerminateRunningThreads;
    procedure AnonumousThreadTerminate(Sender: TObject);
  public
    destructor Destroy; override; final;
    procedure Start(const Procs: array of TProc);
  end;

implementation

{ TAnonumousThreadPool }

procedure TAnonumousThreadPool.Start(const Procs: array of TProc);
var
  T: TThread;
  n: Integer;
begin
  TerminateRunningThreads;

  FThreadList := TThreadList.Create;
  FThreadList.Duplicates := TDuplicates.dupError;

  for n := Low(Procs) to High(Procs) do
  begin
    T := TThread.CreateAnonymousThread(Procs[n]);
    TThread.NameThreadForDebugging(AnsiString('Test thread N:' + IntToStr(n) + ' TID:'), T.ThreadID);
    T.OnTerminate := AnonumousThreadTerminate;
    T.FreeOnTerminate := true;
    FThreadList.LockList;
    try
      FThreadList.Add(T);
    finally
      FThreadList.UnlockList;
    end;
    T.Start;
  end;
end;

procedure TAnonumousThreadPool.AnonumousThreadTerminate(Sender: TObject);
begin
  FThreadList.LockList;
  try
    FThreadList.Remove((Sender as TThread));
  finally
    FThreadList.UnlockList;
  end;
end;

procedure TAnonumousThreadPool.TerminateRunningThreads;
var
  L: TList;
  T: TThread;
begin
  if not Assigned(FThreadList) then
    Exit;
  L := FThreadList.LockList;
  try
    while L.Count > 0 do
    begin
      T := TThread(L[0]);
      T.OnTerminate := nil;
      L.Remove(L[0]);
      T.FreeOnTerminate := False;
      T.Terminate;
      T.Free;
    end;
  finally
    FThreadList.UnlockList;
  end;
  FThreadList.Free;
end;

destructor TAnonumousThreadPool.Destroy;
begin
  TerminateRunningThreads;
  inherited;
end;

end.
